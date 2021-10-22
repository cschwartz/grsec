# frozen_string_literal: true

module Grsec
  class Generator
    def initialize base_path
      @base_path = Pathname.new base_path
      @item_collections = [ControlsCollection.new, RolesCollection.new]
      @collections = {}
      @references = []
    end

    def generate
      load_collections
      parse_collections
      @collections[:controls].items.each { |control| ControlRenderer.new(control).render }
    end

    private

    def load_collections
      @collections = @item_collections.map { |collection| collection_tuple collection }
                                      .to_h
      @references = @collections.transform_values(&:references)
    end

    def parse_collections
      @collections.each_value { |collection| collection.parse @references }
    end

    # :reek:FeatureEnvy
    def parse_collection collection
      definitions = @base_path.glob "#{collection.item_name}/*.rb"
      definitions.each do |file|
        definition = File.read file
        collection.instance_eval definition
      end
      collection
    end

    def collection_tuple collection
      [collection.item_name.to_sym, parse_collection(collection)]
    end
  end
end
