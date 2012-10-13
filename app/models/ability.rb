class Ability
  include CanCan::Ability
  def initialize(user)
    if user.present?
      can :manage, Mailbox, user_id: user.id
      can :index, Folder
    end
  end
end
