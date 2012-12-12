require 'novadb'

# required libs
required_libs = ['mysql']
begin
  required_libs.each { |l| require l }
rescue LoadError
  puts "This script needs the following external libraries: "
  required_libs.each { |l| puts " * #{l}" }
end

class Projects

  attr_accessor :projects

  def initialize
    novadb = NovaDB.new
    master = novadb.master_cloud
    @projects = {}
    begin
      keystone = Mysql.new master[:server], master[:username], master[:password], 'keystone'

      # Get the id and name of all projects 
      project_rs = keystone.query "select id, name from tenant"
      project_rs.each_hash do |row| 
        # Ignore services project
        next if row['name'] == 'services'
        # Give each project a default quota 
        @projects[row['id']] = row['name']
      end
    ensure
      keystone.close if keystone
    end
  end

  def project_names
    @projects.values
  end

  def project_ids
    @projects.keys
  end
end
