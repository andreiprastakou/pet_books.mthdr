# frozen_string_literal: true

# Admin::* subclasses share the same table without STI; treat same-id rows as equal.
module EqualByPersistedId
  extend ActiveSupport::Concern

  def ==(other)
    if other.equal?(self)
      true
    elsif other.is_a?(self.class.base_class)
      !new_record? && !other.new_record? && id == other.id
    else
      false
    end
  end
end
