require 'livejournal'

task 'publish' do
end

task :generate_toc do
  result = File.open("source/reports/_toc.markdown", 'w')
  toc = File.read("source/reports/index.markdown.erb").lines.select { |l| l.match(/^#+/) }
  toc.each do |line|
    m = line.match /^#+ <a id="(.*)"><\/a>(.*)/
    el = "1. [#{m[2]}](##{m[1]})\n"
    if line.match /^##/
      el = '   ' + el
    end
    result.write el
  end
end
