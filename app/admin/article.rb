ActiveAdmin.register Article do
  index do
    column :title
    column :published_at
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :title
      f.input :description, as: :wysihtml5, input_html: {
        toolbar: {
          commands: [ :bold, :italic, :link, :unordered_list, :ordered_list, :source ],
          blocks: [ :h1, :h2, :h3, :p ]
      }}
      f.input :published_at
    end
    f.buttons
  end
end
