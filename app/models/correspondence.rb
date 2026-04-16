class Correspondence < ApplicationRecord
  belongs_to :action
  belongs_to :policy_reference, optional: true
  enum :channel, { letter: 0, email: 1, portal: 2, sms: 3 }
  enum :direction, { outbound: 0, inbound: 1 }
end
