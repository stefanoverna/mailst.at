ActiveAdmin.register Suggestion do
  index do
    column :description
    column :status
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :status
      f.input :description
    end
    f.buttons
  end
end

