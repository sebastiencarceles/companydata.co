# frozen_string_literal: true

FactoryGirl.define do
  factory :search do
    query "MyString"
    user nil
  end
end
