require 'spec_helper'

describe ActiveResource::Base do
  describe 'class method' do
    class DummyClass < ActiveResource::Base; end

    subject { DummyClass }

    it 'responds to find_by_id' do
      expect(subject).to respond_to(:find_by_id)
    end

    it 'responds to find_or_initialize_by_id' do
      expect(subject).to respond_to(:find_or_initialize_by_id)
    end
  end
end
