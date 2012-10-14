ActiveAdmin.register Suggestion do
  index do
    column :description
    column :status
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :status
      f.input :description, as: :wysihtml5, input_html: {
        toolbar: {
          commands: [ :bold, :italic, :link, :unordered_list, :ordered_list, :source ],
          blocks: [ :h1, :h2, :h3, :p ]
      }}
    end
    f.buttons
  end
end

