class ContactSerializer < ApplicationSerializer
  attributes :id, :type, :uid, :email, :given_name, :family_name, :phone_number, :job

  def id  = nil
  def uid = nil
  def job = object.job_title
end
