if ENV['TEST_KITCHEN'] || defined?(ChefSpec)
  module ChefVaultKitchenPatch
    require_relative 'vault_item_not_found_exception.rb'
    require_relative 'helpers.rb'

    def chef_vault_item_or_default(bag, id, default = nil, use_cache = false)
      super bag, id, default, use_cache
    rescue ::ChefSecrets::VaultItemNotFound => e
      unless ::Chef.node.key?('chef_secrets') && ::Chef.node['chef_secrets'].key?(e.bag) && ::Chef.node['chef_secrets'][e.bag].key?(e.id)
        ::Chef::Log.error <<-EOH
No secrets found for #{bag}/#{id}.
You can setup one for your tests by setting the attribute chef_secrets.#{bag}.#{id}!
        EOH
        raise
      end
      ::Chef.node['chef_secrets'][e.bag][e.id]
    end
  end

  ::Chef::Log.warn 'Monkey patching chef_vault_item_or_default for tests'
  module ChefVaultCookbook
    prepend ChefVaultKitchenPatch
  end
  Chef::Node.send(:include, ChefVaultCookbook)
  Chef::Recipe.send(:include, ChefVaultCookbook)
  Chef::Resource.send(:include, ChefVaultCookbook)
  Chef::Provider.send(:include, ChefVaultCookbook)
end
