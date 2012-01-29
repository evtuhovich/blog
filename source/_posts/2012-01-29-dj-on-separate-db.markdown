---
layout: post
title: Delayed_job в отдельной базе данных
date: 2012-01-29 23:08
comments: true
categories: delayed_job, dj, "secondary db", "separate db"
---

Как я уже когда-то [писал](/blog/2009/05/19/two-databases/), иногда проект дорастает до того, что ему не хватает одной
базы данных. И тогда можно сделать вторую. Вопрос, какие таблицы переносить во вторую базу данных, всегда остается
открытым. В нашем случае, поскольку на сервере БД очень много памяти и слабая дисковая подсистема, мне показалось
разумным перенести туда таблицы, в которые идет интенсивная запись. И эти таблицы не должны быть «связаны», то есть
перенос их должен быть простым.

<!-- more -->

Вот такой запрос показывает потенциальных кандидатов на переезд.

{% codeblock lang:sql %}
SELECT
	relname, n_tup_ins + n_tup_upd + n_tup_del
FROM
	pg_stat_user_tables 
ORDER BY
	2
{% endcodeblock %}

В нашем случае это оказалась таблица, где сохранялись ip-адреса, с которых пользователи заходят на сайт, и
таблица `delayed_jobs`. В rails 2.3 делалось это очень просто.

{% codeblock config/initializers/delayed_job_config.rb %}
class Delayed::Backend::ActiveRecord::Job
  establish_connection "second_#{Rails.env}"
end
{% endcodeblock %}

В случае же с rails 3, на которые вот уже совсем скоро переедет Групон, все оказалось не так просто. Gem `delayed_jobs`
версии 2.1.4 достаточно сильно отличается от версии 2.0. Поэтому старый трюк работать перестал. Гугление не помогло,
поэтому пришлось залесть в его исходники, понять, чего там внутри происходит, и сделать вот такой monkey-patch.

{% codeblock config/initializers/delayed_job_config.rb %}
Delayed::Worker.backend = SecondDbDj
{% endcodeblock %}

{% codeblock  app/models/second_db_dj.rb %}
class SecondDbDj < SecondDb # это абстрактный класс, который подключает ко второй БД
  include Delayed::Backend::Base
  set_table_name :delayed_jobs

  before_save :set_default_run_at

  scope :ready_to_run, lambda {|worker_name, max_run_time|
    where(['(run_at <= ? AND (locked_at IS NULL OR locked_at < ?) OR locked_by = ?) AND failed_at IS NULL', db_time_now,
db_time_now - max_run_time, worker_name])
  }
  scope :by_priority, order('priority ASC, run_at ASC')

  def self.before_fork
    ::ActiveRecord::Base.clear_all_connections!
  end

  def self.after_fork
    ::ActiveRecord::Base.establish_connection
  end

  # When a worker is exiting, make sure we don't have any locked jobs.
  def self.clear_locks!(worker_name)
    update_all("locked_by = null, locked_at = null", ["locked_by = ?", worker_name])
  end

  # Find a few candidate jobs to run (in case some immediately get locked by others).
  def self.find_available(worker_name, limit = 5, max_run_time = Delayed::Worker.max_run_time)
    scope = self.ready_to_run(worker_name, max_run_time)
    scope = scope.scoped(:conditions => ['priority >= ?', Delayed::Worker.min_priority]) if Delayed::Worker.min_priority
    scope = scope.scoped(:conditions => ['priority <= ?', Delayed::Worker.max_priority]) if Delayed::Worker.max_priority

    ::ActiveRecord::Base.silence do
      scope.by_priority.all(:limit => limit)
    end
  end

  # Lock this job for this worker.
  # Returns true if we have the lock, false otherwise.
  def lock_exclusively!(max_run_time, worker)
    now = self.class.db_time_now
    affected_rows = if locked_by != worker
      # We don't own this job so we will update the locked_by name and the locked_at
      self.class.update_all(["locked_at = ?, locked_by = ?", now, worker], ["id = ? and (locked_at is null or locked_at
< ?) and (run_at <= ?)", id, (now - max_run_time.to_i), now])
    else
      # We already own this job, this may happen if the job queue crashes.
      # Simply resume and update the locked_at
      self.class.update_all(["locked_at = ?", now], ["id = ? and locked_by = ?", id, worker])
    end
    if affected_rows == 1
      self.locked_at = now
      self.locked_by = worker
      self.locked_at_will_change!
      self.locked_by_will_change!
      return true
    else
      return false
    end
  end

  # Get the current time (GMT or local depending on DB)
  # Note: This does not ping the DB to get the time, so all your clients
  # must have syncronized clocks.
  def self.db_time_now
    if Time.zone
      Time.zone.now
    elsif ::ActiveRecord::Base.default_timezone == :utc
      Time.now.utc
    else
      Time.now
    end
  end

end
{% endcodeblock %}

Эта огромная простыня отличается от того, что находится в `delayed_job` всего тремя строчками. Если кто-то знает более
простой способ сделать то же самое, я буду рад об этом узнать.
