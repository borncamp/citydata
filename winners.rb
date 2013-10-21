
owners={}
File.open(ARGV[0]).each_line do |line|
  owner=line.split(',')[13]
  count=owners[owner]
  begin
    owners[owner]=count+1
  rescue
    owners[owner]=1
  end
end
#owners.sort_by {|name, number| number}.reverse!

owners.each do |owner|
  puts  owner[1].to_s+","+owner[0].to_s
end
