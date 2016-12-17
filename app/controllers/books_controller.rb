class BooksController < ApplicationController

  load_and_authorize_resource :only => [:index, :show]

  before_action :find_book
  before_filter :authenticate_user!
  before_action :check_if_admin, only: [:destroy]

  def index
    if current_user.admin?
      @books = Book.all
    else
      @books = current_user.books
    end

    respond_to do |format|
      format.html
      format.csv { send_data @books.to_csv }
    end

  end


  def import
    Book.import(params[:file], current_user)
    redirect_to books_path, notice: "Book imported."
  end

  def show
    unless @book
      render text: "Page not found", status: 404
    end
  end

  def new
    @book = Book.new
  end

  def create
    book_params = params.require(:book).permit!
    @book = current_user.books.create(book_params)
    if @book.errors.empty?
      redirect_to books_path # /books/:id
    else
      render "new"
    end
  end


  def edit
  end


  # /note/1 PUT
  def update
    @book.update_attributes(params.require(:book).permit!)
    if @book.errors.empty?
      redirect_to book_path(@book)
    else
      render "edit"
    end
  end

  def destroy
    @book.destroy
     redirect_to action: "index"
    #render json: { success: true }
    #render books_path
  ##  ItemsMailer.item_destroyed(@item).deliver
  end


  private
  def find_book
    @book = Book.where(id: params[:id]).first
    # render_404 unless @book
  end



end