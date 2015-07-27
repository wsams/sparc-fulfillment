require 'factory_girl'

namespace :data do

  desc 'Import data from Sparc-Request to Sparc-Fulfillment'
  task import_data: :environment do

    # Destroy Old Fake Data
    clean_old_fake_data

    # Create Indentity
    identity = FactoryGirl.create(:identity, email: 'email@musc.edu', ldap_uid: 'ldap@musc.edu', password: 'password')

    # Use SparcFulfillmentImporter to import 10 sub_service_requests
    proto_ssr_hash = SparcFulfillmentImporter.import_count(10)

    # Give access to global identity ldap@musc.edu
    proto_ssr_hash.each do |protocol_id, ssr_id|
      org_id = SubServiceRequest.find(ssr_id).organization_id
      FactoryGirl.create(:clinical_provider, identity_id: identity.id, organization_id: org_id)
      FactoryGirl.create(:project_role_pi, identity_id: identity.id, protocol_id: protocol_id)
    end

  end
end

def clean_old_fake_data # from the sparc side
  fake_identities = Identity.where( email: "email@musc.edu")                        # find fake identities
  fake_identities.each{ |dent| dent.project_roles.destroy_all }                     # destroy fake project roles
  fake_identities.each{ |dent| dent.clinical_providers.destroy_all }                # destroy fake clinical providers
  fake_identities.destroy_all                                                       # destroy fake identities
end
