class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, format: { with: /\A[^@\s]+@riverdaleparkmd\.gov\z/i,
    message: "Must be a riverdaleparkmd.gov email address" }
        
    has_many :comments
    has_many :addresses, through: :comments

    has_many :violations

  end
