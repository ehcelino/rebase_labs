require 'pg'

@conn = PG.connect(host:'postgres', user:'postgres')

@conn.exec('DROP TABLE patients CASCADE')
@conn.exec('DROP TABLE doctors CASCADE')
@conn.exec('DROP TABLE tokens CASCADE')
@conn.exec('DROP TABLE exams CASCADE')