class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, format: { with: /\A[^@\s]+@riverdaleparkmd\.gov\z/i,
    message: "Must be a riverdaleparkmd.gov email address" }
        
    has_many :comments
    has_many :addresses, through: :comments
    has_many :violation_comments, dependent: :destroy
    has_many :citation_comments, dependent: :destroy
    has_many :contact_comments, dependent: :destroy
    has_many :inspection_comments, dependent: :destroy

    has_many :violations
    has_many :citations, through: :violations
    has_many :inspections, foreign_key: :assignee_id
    has_many :inspections, foreign_key: "inspector_id"

    has_many :notifications

    has_paper_trail

    def email_without_domain
      email.split("@").first.titleize
    end


    enum role: { guest: 0, ons: 1, oas: 2, admin: 3 }
  end
