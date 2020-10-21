require 'test_helper'

ActiveRecord::Migration.create_table :people, :force => true do |t|
  t.string :name
  t.integer :father_id
end

class Person < ActiveRecord::Base
  has_many :children, primary_key: :id, foreign_key: :father_id, class_name: 'Person'
  belongs_to :father, primary_key: :father_id, foreign_key: :id, class_name: 'Person'
end

class SameTableTest < Minitest::Test
  def setup
    ActiveRecord::Base.descendants.each(&:delete_all)
  end

  def test_belongs_to
    child = Person.create!
    _father = child.create_father!

    result = Person.where_exists(:father)

    assert_equal 1, result.length
    assert_equal result.first.id, child.id
  end

  def test_belongs_to_two_levels
    child = Person.create!
    father = child.create_father!
    _grandfather = father.create_father!

    result = Person.where_exists(:father) { |father_scope| father_scope.where_exists(:father) }

    assert_equal 1, result.length
    assert_equal result.first.id, child.id
  end

  def test_has_many
    child = Person.create!
    father = child.create_father!

    result = Person.where_exists(:children)

    assert_equal 1, result.length
    assert_equal result.first.id, father.id
  end
end