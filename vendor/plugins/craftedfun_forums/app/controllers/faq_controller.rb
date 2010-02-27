class FaqController < ApplicationController

  unloadable

  before_filter :set_faq_pairs

  def index

    @back_link[:name] = "<b><< Back to Help & Discussion</b>"
    @back_link[:location] = "/forums"

    @default_question_id = params[:default_question_id].to_i  if params[:default_question_id]

    render("faq/index_plain", :layout => "unstyled") unless @rails_user
  end

  def set_faq_pairs
    if @faq_pairs
      @faq_pairs
    else

      @faq_pairs = [ ]

      Faq.all.each do |faq|
        @faq_pairs << { :question => faq.question, :answer => faq.answer}
      end

    end
  end

end
