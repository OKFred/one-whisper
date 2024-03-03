import whisper
import os
import time
import sys
import warnings
from openai import OpenAI

def transcribe_audio(audio_path, is_fast_mode):
  # 询问用户选择哪个模型
  model_size = ''
  if is_fast_mode:
    model_size = 'small'
  else:
    print("将使用中等模型，以获得更好的识别结果。")
    model_size = 'medium'
  # 加载模型
  model = whisper.load_model(model_size)
  
  while True:
    # 提示用户输入路径
    if audio_path:
      print("使用传参的音频文件的路径：", audio_path)
    else:
      audio_path = input("请输入音频文件的路径：")
    audio_path = audio_path.strip('"')  # 自动删除前后的双引号
    
    # 检查文件是否存在
    if os.path.exists(audio_path):
      print("正在处理中，请稍等...")
      start_time = time.time()  # 开始计时
      # 运行语音识别
      result = model.transcribe(audio_path)
      end_time = time.time()  # 结束计时
      print(f"语音识别耗时：{end_time - start_time:.2f}秒")
      output_test = '' # 保存输出结果
      print("\n识别结果：")
      for segment in result["segments"]:
        #start 和 end 保留1位小数
        segment['start'] = round(segment['start'], 1)
        segment['end'] = round(segment['end'], 1)
        print(f"{segment['start']}-{segment['end']}：{segment['text']}")
        output_test += f"{segment['start']}-{segment['end']}：{segment['text']}\n"
      # 询问用户是否需要概括内容
      need_summary = input("是否需要概括内容？(y/n)")
      if need_summary not in ['y', 'n']:
        print("使用默认值(n)")
      elif need_summary == 'y':
        print("正在概括...")
        summaries = summarize_text(result["text"])
        output_test += f"\n\n概括：\n{summaries}"
        print(summaries)
      # 保存输出结果到文件，文件名为音频文件名+“_识别结果.txt”
      file_name = os.path.basename(audio_path) + "_识别结果.txt"
      with open(file_name, "w", encoding="utf-8") as f:
        f.write(output_test)
      print(f"结果已保存到 {file_name}")
      break  # 成功转换后退出循环
    else:
      print("文件不存在，请重新输入路径。")

def summarize_text(text):
  """
  使用 OpenAI GPT-4 来总结文本，适用于 openai>=1.0.0。
  """
  api_key = input("请输入openAI的密钥(api_key): ")
  if not api_key:
      print("未输入api_key。")
      # 这里可以添加更多的处理代码，例如提示用户重新输入或退出程序等
      return "无法生成摘要。"
  else:
      print("已输入api_key：", api_key)
      # 继续处理api_key
  client = OpenAI(
    api_key=api_key,
  )

  try:
    chat_completion = client.chat.completions.create(
      model="gpt-4-1106-preview",
      messages=[
        {"role": "system", "content": "你是一个高级的AI，能够提供准确的信息和总结。"},
        {"role": "user", "content": f"请总结以下内容：\n{text}"}
      ],
      temperature=0.7,
      max_tokens=500,
      top_p=1.0,
      frequency_penalty=0.0,
      presence_penalty=0.0
    )
    summary = chat_completion.choices[0].message.content
    return summary
  except Exception as e:
    print(f"生成摘要时发生错误：{e}")
    return "无法生成摘要。"

# 主程序

# 抑制所有警告
def main(): 
# 读取传参，是否有提到debug
  is_debug = False
  is_fast_mode = True
  audio_path = ''
  
  
  if len(sys.argv):
    for i in range(len(sys.argv)):
      if sys.argv[i] == "debug":
        is_debug = True
      if sys.argv[i] == "audio_path":
        audio_path = sys.argv[i+1]
      if sys.argv[i] == "fast":
        is_fast_mode = False
  if is_debug == False:
    warnings.filterwarnings("ignore")
  transcribe_audio(audio_path, is_fast_mode)

  # 在脚本末尾添加
  input("按回车键退出...")

main()

# debian下运行示例： python3 main.py audio_path /root/test.m4a debug fast