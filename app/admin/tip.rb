ActiveAdmin.register Tip do
  index do
    column :title
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :title
      f.input :description
      f.input :citation
    end
    f.buttons
  end
end
