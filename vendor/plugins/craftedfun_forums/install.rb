# Install hook code here
puts "Welcome to the Crafted Fun Forums plugin!"

puts "\nNow checking that you have a 'user' model..."
user_model_file = "#{Rails.root}/app/models/user.rb"
if FileTest.exists?(user_model_file)
  puts "\tYou have a user model!  That's good."
else
  puts "************************************************************"

  puts "* WARNING * WARNING * WARNING * WARNING * WARNING * WARNING * WARNING *"
  puts "Your application does not have a user model.  This plugin requires that you have one."
  puts "Exiting the installation.  Please re-install this plugin after a user model exists."

  puts "************************************************************"
  Process.exit
end

puts "\nNow checking that the Facebooker plugin is installed..."
facebooker_plugin = "#{Rails.root}/vendor/plugins/facebooker"
if FileTest.exists?(facebooker_plugin)
  puts "\tYou have installed the Facebooker plugin  That's good."
else
  puts "************************************************************"

  puts "* WARNING * WARNING * WARNING * WARNING * WARNING * WARNING * WARNING *"
  puts "You have not installed the Facebooker plugin for this application.  Without it, "
  puts "this engine will not work."

  puts "Please install Facebooke, and then re-install this plugin."

  puts "************************************************************"
  Process.exit
end

puts "\nNow copying database migrations..."
system "rsync -ruv #{Rails.root}/vendor/plugins/craftedfun_forums/db/migrate #{Rails.root}/db"

puts "\nNow copying public files..."
system "rsync -ruv #{Rails.root}/vendor/plugins/craftedfun_forums/public ."

puts "\nDone installing!"

puts "\nNote that your user model must define the following public methods: "
puts "\t- TO BE ENTERED"

puts "Meanwhile, enjoy this engine..."

