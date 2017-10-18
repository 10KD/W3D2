require 'sqlite3'
require 'singleton'
class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('test.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end


class User
  attr_accessor :fname, :lname

  def average_karma
    

  end


  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      users
    WHERE
      id = ?
    SQL
    return nil if user.length < 1

    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      fname = ?
      AND
      lname = ?
    SQL

    return nil if user.length < 1
    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end



end


class Question
  attr_accessor :title, :body, :users_id

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def self.most_followed(n)
     QuestionFollow.most_followed_questions(n)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def author
    User.find_by_id(@users_id)

  end

  def replies
    Reply.find_by_question_id(@id)

  end




  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL,author_id)

    SELECT
      *
    FROM
      questions
    WHERE
      users_id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end



  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      questions
    WHERE
      id = ?
    SQL
    return nil if question.length < 1

    Question.new(question.first)
  end



  def initialize(options)
    @id = options['id']
    @title= options['title']
    @body = options['body']
    @users_id = options['users_id']

  end

end

class Reply
  attr_accessor :body, :user_id, :question_id, :parent_reply_id

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_reply_id)
  end

  def child_replies
    replies = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      *
    FROM
      replies
    WHERE
      parent_reply_id = ?
    SQL

    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      replies
    WHERE
      user_id = ?
    SQL

    replies.map { |user| Reply.new(user) }
  end

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      replies
    WHERE
      id = ?
    SQL
    return nil if reply.length < 1

    Reply.new(reply.first)
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      replies
    WHERE
      question_id = ?
    SQL

    replies.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @user_id = options['user_id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
  end
end


class QuestionFollow
  attr_accessor :user_id, :question_id



  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL,n)
    SELECT
      title, body, users_id
    FROM
      question_follows
    JOIN
      questions
    ON
      questions.id = question_id
    GROUP BY
      question_id
    ORDER BY
      count(question_id) DESC
    LIMIT
      ?

    SQL
    return nil if questions.length < 1
    questions.map {|question| Question.new(question)}
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      user_id,fname,lname,
    FROM
      question_follows
    INNER JOIN
      users
    ON
      user_id = users.id
    WHERE
      question_id = ?

    SQL
    return nil if followers.length < 1
    followers.map {|user| User.new(user)}
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.intance.execute(<<-SQL, user_id)
    SELECT
      title, body, user_id
    FROM
      question_follows
    INNER JOIN
      questions
    ON
      question_id = questions.id
    WHERE
    user_id = ?

    SQL
    questions.map { |question| Question.new(question) }
  end




  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.find_by_id(id)
    parent_reply = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      question_follows
    WHERE
      id = ?
    SQL
    return nil if parent_reply.length < 1

    Reply.new(parent_reply.first)
  end


end


class QuestionLike
  attr_accessor :user_id, :question_id

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL,n)

    SELECT
      title, body, users_id
    FROM
      question_likes
    JOIN
      questions
    ON
      questions.id = question_id
    GROUP BY
      question_id
    ORDER BY
      count(question_id) DESC
    LIMIT
      ?

    SQL
    return nil if questions.length < 1
    questions.map {|question| Question.new(question)}


  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']

  end

  def self.find_by_id(id)
    like = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      question_likes
    WHERE
      id = ?
    SQL

    return nil if like.length < 1

    QuestionLike.new(like.first)
  end


  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL,question_id)

    SELECT
      users.id, fname,lname, question_id
    FROM
      question_likes
    JOIN
      users
    ON
      users.id = user_id

    WHERE
      question_id = ?

    SQL
    return nil if likers.length < 1
    likers.map { |liker| User.new(liker) }
  end

  def self.num_likes_for_question_id(question_id)
    count = QuestionsDatabase.instance.execute(<<-SQL,question_id)
    SELECT
      count(question_id) AS likes_count
    FROM
      question_likes
    JOIN
      users
    ON
      users.id = user_id
    WHERE
      question_id = ?
    SQL
    count
  end

  def self.liked_questions_for_user_id(user_id)
    liked_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      title, body, user_id
    FROM
      question_likes
    JOIN
      questions
    ON
      question_id = questions.id
    WHERE
      user_id = ?
    SQL
    liked_questions.map { |question| Question.new(question)}
  end
end
