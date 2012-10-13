class FoldersController < ApplicationController
  load_and_authorize_resource
  inherit_resources
  belongs_to :mailbox

  respond_to :html
end
