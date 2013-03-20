f = File.open('go_terms.annot')
go_terms = {}
while not f.eof?
  line = f.readline
  next if line.strip.empty?
  (transcript, go_id, go_term) = line.split(/\s+/)
  go_terms[go_id] = go_term
end
puts "Number of go ids = #{go_terms.keys.count}"
f.close
