# frozen_string_literal: true

module XmlHasher
  class Node
    attr_accessor :name, :attributes, :children, :text

    def initialize(name)
      @name = name
      @attributes = {}
      @children = []
    end

    def to_hash
      node_content = content
      { name => node_content.empty? ? nil : node_content }
    end

    private

    def content
      return text if text && !text.empty?

      attributes_to_hash.merge(children_to_hash)
    end

    def attributes_to_hash
      attributes.each_with_object({}) do |(key, value), data|
        next if value.nil? || value.to_s.empty?

        data[key] = value
      end
    end

    def children_to_hash
      return children.first.to_hash if children.size == 1

      children.group_by(&:name).each_with_object({}) do |(key, nodes), data|
        next data.merge!(nodes.first.to_hash) if nodes.length == 1

        data[key] = nodes.map do |node|
          node.to_hash[node.name]
        end
      end
    end
  end
end
