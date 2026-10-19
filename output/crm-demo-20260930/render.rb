require 'json'
require 'open3'
root = File.expand_path(__dir__)
frames = JSON.parse(File.read(File.join(root, 'frames.json')))
# Preserve every captured frame in order; shorten idle gaps over eight seconds.
clock = 0.0
lines = ["ffconcat version 1.0"]
frames.each_with_index do |frame, i|
  seconds = i == frames.length - 1 ? 12.0 : [[frames[i + 1]['timestamp'] - frame['timestamp'], 0.04].max, 8.0].min
  lines << "file 'frames/#{frame.fetch('file')}'"
  lines << format('duration %.6f', seconds)
  frame['edited_start'] = clock
  clock += seconds
end
lines << "file 'frames/#{frames.last.fetch('file')}'"
File.write(File.join(root, 'captura.ffconcat'), lines.join("\n") + "\n")
File.write(File.join(root, 'timeline.json'), JSON.pretty_generate({duration: clock, frames: frames}))
def stamp(seconds)
  ms = (seconds * 1000).round
  format('%02d:%02d:%02d,%03d', ms / 3600000, ms / 60000 % 60, ms / 1000 % 60, ms % 1000)
end
captions = "1\n00:00:00,000 --> #{stamp(clock-15)}\nCaptura real de MCP privado. No valida las skills del ZIP.\n\n2\n#{stamp(clock-15)} --> #{stamp(clock)}\nN3 FALLA: solicita el documento. No se proporcionó ni guardó un número.\n"
File.write(File.join(root,'aclaraciones.srt'), captions)
args = ['ffmpeg','-hide_banner','-loglevel','warning','-nostdin','-n','-safe','0','-i',File.join(root,'captura.ffconcat'),'-i',File.join(root,'aclaraciones.srt'),'-map','0:v:0','-map','1:s:0','-vf','pad=ceil(iw/2)*2:ceil(ih/2)*2','-r','30','-c:v','libx264','-preset','fast','-crf','20','-pix_fmt','yuv420p','-c:s','mov_text','-disposition:s:0','default','-metadata:s:s:0','language=spa','-movflags','+faststart',File.join(root,'padma-crm-demo.mp4')]
abort 'Export failed' unless system(*args)
puts JSON.generate({frames: frames.length, edited_seconds: clock, output: File.join(root,'padma-crm-demo.mp4')})
