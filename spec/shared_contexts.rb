# optional, this should be the path to where the hiera data config file is in this repo
# You must update this if your actual hiera data lives inside your module.
# I only assume you have a separate repository for hieradata and its include in your .fixtures
hiera_config_file = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures','modules','hieradata', 'hiera.yaml'))

# hiera_config and hiera_data are mutually exclusive contexts.

shared_context :global_hiera_data do
  let(:hiera_data) do
     {
       #"exiscan::default_exim_sources" => '',
       #"exiscan::dkim_domain" => '',
       #"exiscan::dkim_private_key" => '',
       #"exiscan::exim_source_dir" => '',
       #"exiscan::greylist_db::db_name" => '',
       #"exiscan::greylist_db::db_password" => '',
       #"exiscan::greylist_db::db_type" => '',
       #"exiscan::greylist_db::db_username" => '',
       #"exiscan::greylist_db::exim_ipaddress" => '',
       #"exiscan::greylist_dsn" => '',
       #"exiscan::greylist_local" => '',
       #"exiscan::greylist_sql_password" => '',
       #"exiscan::greylist_sql_username" => '',
       #"exiscan::junk_submitters" => '',
       #"exiscan::listen_ipaddresses" => '',
       #"exiscan::local_delivery" => '',
       #"exiscan::master" => '',
       #"exiscan::other_hostnames" => '',
       #"exiscan::relay_domains" => '',
       #"exiscan::relay_nets" => '',
       #"exiscan::sa_bayes_sql_dsn" => '',
       #"exiscan::sa_bayes_sql_local" => '',
       #"exiscan::sa_bayes_sql_password" => '',
       #"exiscan::sa_bayes_sql_username" => '',
       #"exiscan::sa_trusted_networks" => '',
       #"exiscan::spamassassin::bayes_sql_dsn" => '',
       #"exiscan::spamassassin::bayes_sql_password" => '',
       #"exiscan::spamassassin::bayes_sql_username" => '',
       #"exiscan::spamassassin::custom_rules_content" => '',
       #"exiscan::spamassassin::custom_rules_source" => '',
       #"exiscan::spamassassin::trusted_networks" => '',
       #"exiscan::spamassassin_db::db_name" => '',
       #"exiscan::spamassassin_db::db_password" => '',
       #"exiscan::spamassassin_db::db_type" => '',
       #"exiscan::spamassassin_db::db_username" => '',
       #"exiscan::spamassassin_db::exim_ipaddress" => '',
     
     }
  end
end

shared_context :hiera do
    # example only,
    let(:hiera_data) do
        {:some_key => "some_value" }
    end
end

shared_context :linux_hiera do
    # example only,
    let(:hiera_data) do
        {:some_key => "some_value" }
    end
end

# In case you want a more specific set of mocked hiera data for windows
shared_context :windows_hiera do
    # example only,
    let(:hiera_data) do
        {:some_key => "some_value" }
    end
end

# you cannot use this in addition to any of the hiera_data contexts above
shared_context :real_hiera_data do
    let(:hiera_config) do
       hiera_config_file
    end
end
