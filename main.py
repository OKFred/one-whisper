import whisper
import os
import time
import argparse
import warnings
import subprocess  # 用于调用ffmpeg
from openai import OpenAI

def transcribe_audio(audio_path, is_fast_mode):
  model_size = 'small' if is_fast_mode else 'medium'
  print("将使用" + ("小型模型，速度较快。" if is_fast_mode else "中等模型，以获得更好的识别结果。"))
  model = whisper.load_model(model_size)
  
  if not audio_path:
    audio_path = input("请输入音视频文件的路径：").strip('"')

  if not os.path.exists(audio_path):
    print("文件不存在。")
    return
  else:
    print("正在处理中，请稍等...")
    start_time = time.time()
    result = model.transcribe(audio_path)
    end_time = time.time()
    print(f"语音识别耗时：{end_time - start_time:.2f}秒")

    output_text = ''
    output_srt = ''
    counter = 1
    for segment in result["segments"]:
      start = round(segment['start'], 1)
      end = round(segment['end'], 1)
      text_segment = f"{start}-{end}：{segment['text']}"
      print(text_segment)
      output_text += text_segment + "\n"
      # SRT segment
      srt_start = convert_to_srt_time(start)
      srt_end = convert_to_srt_time(end)
      output_srt += f"{counter}\n{srt_start} --> {srt_end}\n{segment['text']}\n\n"
      counter += 1

    text_file_name = os.path.basename(audio_path) + "_识别结果.txt"
    srt_file_name = os.path.basename(audio_path) + "_识别结果.srt"
    with open(text_file_name, "w", encoding="utf-8") as f:
      f.write(output_text)
    with open(srt_file_name, "w", encoding="utf-8") as f:
      f.write(output_srt)
    print(f"结果已保存到 {text_file_name} 和 {srt_file_name}")
    if audio_path.lower().endswith('.mp4'):
        subtitle_video(audio_path, srt_file_name)


def convert_to_srt_time(seconds):
  hours = int(seconds // 3600)
  minutes = int((seconds % 3600) // 60)
  seconds = seconds % 60
  milliseconds = int((seconds - int(seconds)) * 1000)
  return f"{hours:02}:{minutes:02}:{int(seconds):02},{milliseconds:03}"


def subtitle_video(video_path, srt_path):
    user_input = input("是否需要将字幕合成到视频文件中？(y/n): ")
    if user_input.lower() == 'y':
        font_color = input("请输入字体颜色(如 0080FF) 或按回车使用默认值 (白色): ")
        font_size = input("请输入字体大小(如 18) 或按回车使用默认值 (18): ")
        font_color = font_color if font_color else 'FFFFFF'  # 默认白色
        font_size = font_size if font_size else '18'           # 默认大小18
        output_video_path = os.path.splitext(video_path)[0] + "_带字幕.mp4"
        command = [
            'ffmpeg', '-i', video_path, '-vf', 
            f"subtitles={srt_path}:force_style='Fontsize={font_size},FontName=Calibri,PrimaryColour=&H{font_color}'", output_video_path
        ]
        subprocess.run(command, check=True)
        print(f"带字幕的视频已保存到 {output_video_path}")

def summarize_text(text):
  api_key = input("请输入openAI的密钥(api_key): ")
  if not api_key:
      return "无法生成摘要。"
  client = OpenAI(api_key=api_key)
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
def main(): 
  parser = argparse.ArgumentParser(description="语音识别", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
  parser.add_argument("--file", type=str, help="音频文件的路径")
  parser.add_argument("--fast", action="store_true", help="是否使用快速模式")
  parser.add_argument("--debug", action="store_true", help="是否使用调试模式")
  args = parser.parse_args()
  if args.debug:
    warnings.filterwarnings("ignore")
  transcribe_audio(args.file, args.fast)

main()
