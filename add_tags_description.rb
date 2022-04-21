require 'fileutils'

tags = %w(activerecord
airbrake
apt-get
backup
barman
books
caches_action
capistrano
chef
codefest
configuration-management
continuous-delivery
continuous-integration
cruisecontrol
delayed_job
deploy
devise
devops
gem
git
hashwithindifferentaccess
hstore
json
key-value
knife
londiste
memcache
osx
package-manager
paperclip
partitioning
pathogen
performance
pg_reorg
pg_repack
pgbadger
pgbench
pgbouncer
pgq
podcast
postgresql
powershell
rails
railsclub
rollback
rspec
ruby-debug
rubynoname
state-of-devops
toster
transaction
vagrant
validates_uniqueness_of
vim
wal-e
warden
yaml
блокирвоки
др
еда
индексы
кино
книги
конвей
конференция
курение
литвак
миграция
микросервисы
музыка
мысли
никита
пост
семья
ульяновск)

tags.each do |tag|
  FileUtils.mkdir_p("content/tags/#{tag}")

  f = File.open("content/tags/#{tag}/_index.md", "w")

  f.write("---\n")
  f.write("title: \"Записи с тегом: #{tag}\"\n")
  f.write("description: \"Все записи из блога тегом: #{tag}\"\n")
  f.write("----\n")
  f.close
end