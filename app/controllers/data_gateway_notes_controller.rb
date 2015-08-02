class DataGatewayNotesController < ApplicationController

  def create
    begin
      note = DataGatewayNote.create!(gateway_id: params[:gateway_id],
                                    user_id: params[:user_id],
                                    note: params[:note])
      gateway_title = DataGateway.find(params[:gateway_id]).title rescue 'Which has been deleted.'
      note.create_activity :key => 'data_gateway_note.create',
                           :owner => current_user, :trackable_title => gateway_title,
                           :user_title => user_title,
                           :parameters => {gateway_id: params[:gateway_id]}
      render json: {error: 0, message: 'success', data: note, user: User.find(note.user_id).title}
    rescue => e
      render json: {error: 1, message: e.message}
    end
  end

  def destroy
    begin
      note = DataGatewayNote.find(params[:note_id])
      render json: {error: 0, message: 'Deleted'} if note.destroy
    rescue => e
      render json: {error: 1, message: e.message}
    end
  end

  def update
    begin
      note = DataGatewayNote.find(params[:note_id])
      render json: {error: 0, message: 'Update success', data: note} if note.update_attributes!(note: params[:note])
    rescue => e
      render json: {error: 0, message: e.message}
    end
  end

end
