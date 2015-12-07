file "/tmp/helloworld.txt" do
  owner "ubuntu"
  group "ubuntu"
  mode 00544
  action :create
  content "Hello, Implementor!"
end