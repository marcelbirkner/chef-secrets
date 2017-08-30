module ChefSecrets
  class VaultItemNotFound < RuntimeError
    attr_reader :bag, :id
    def initialize(bag, id)
      @bag = bag
      @id = id
      super "Cannot load vault item #{id} from #{bag}, and no default value is defined"
    end
  end
end