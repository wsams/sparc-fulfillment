desc "Script to fix data after the IDS split/notify move"
task :fix_split_notify => :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  def get_file(error=false)
    puts "No import file specified or the file specified does not exist in db/imports" if error
    file = prompt "Please specify the file name to import from db/imports (must be a CSV): "

    while file.blank? or not File.exists?(Rails.root.join("db", "imports", file))
      file = get_file(true)
    end

    file
  end

  puts ""
  puts "Reading in file..."
  input_file = Rails.root.join("db", "imports", get_file)
  continue = prompt('Preparing to modify the data. Are you sure you want to continue? (y/n): ')

  if (continue == 'y') || (continue == 'Y')
    ActiveRecord::Base.transaction do
      CSV.foreach(input_file, :headers => true) do |row|
        line_item = LineItem.where(id: row['Line Item ID'].to_i).first
        if line_item
          if row['Create or Assign'] == 'Create'
            protocol = Protocol.create(sparc_id: row['Sparc ID'].to_i, sponsor_name: row['Sponsor Name'],
                                       udak_project_number: row['Udak Number'], start_date: row['Start Date'],
                                       end_date: row['End Date'], recruitment_start_date: row['recruitment_start'],
                                       recruitment_end_date: row['Recruitment End'], study_cost: row['Study Cost'].to_i,
                                       sub_service_request_id: row['New SSR ID'])
            line_item.update_attributes(protocol_id: protocol.id)
        else
          puts 'Line item not found'
        end 
      end
    end
  else
    puts "Exiting rake task..."
  end
end