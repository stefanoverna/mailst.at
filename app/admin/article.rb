ActiveAdmin.register Article do
  index do
    column :title
    column :published_at
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :title
      f.input :description
      f.input :published_at
    end
    f.buttons
  end
end
