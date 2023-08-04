require 'csv'
require 'pg'

class TransferData

  def self.make_transfer(csv, option = '')
    puts 'Iniciando importação do arquivo - aguarde...'
    if ENV['APP_ENV'] == 'test'
      begin
        PG.connect(host:'postgres', user:'postgres', password:'postgres').exec('CREATE DATABASE test')
      rescue
        puts 'Database teste já existe'
      end
      conn = PG.connect(host:'postgres', user:'postgres', password:'postgres', dbname:'test')
    else
      conn = PG.connect(host:'postgres', user:'postgres', password:'postgres')
    end
    hash_data = self.read_csv(csv, option)
    self.create_tables(conn)
    hash_data.each do |row|
      self.insert_patients(row, conn)
      self.insert_doctors(row, conn)
      self.insert_tokens(row, conn)
      self.insert_exams(row, conn)
    end
    conn.close
    puts 'Importação do arquivo finalizada.'
  end

  def self.create_tables(conn)
    conn.exec('CREATE TABLE IF NOT EXISTS patients 
                                          (cpf VARCHAR(11) PRIMARY KEY,
                                          name VARCHAR,
                                          email VARCHAR,
                                          birth_date DATE,
                                          address VARCHAR,
                                          city VARCHAR,
                                          state VARCHAR);')
    conn.exec('CREATE TABLE IF NOT EXISTS doctors 
                                          (crm VARCHAR(10) PRIMARY KEY,
                                          crm_state VARCHAR,
                                          name VARCHAR,
                                          email VARCHAR);')
    conn.exec('CREATE TABLE IF NOT EXISTS tokens 
                                          (value VARCHAR(6) PRIMARY KEY,
                                          id_cpf VARCHAR(11) REFERENCES patients(cpf),
                                          id_crm VARCHAR(10) REFERENCES doctors(crm))')
    conn.exec('CREATE TABLE IF NOT EXISTS exams 
                                          (token VARCHAR(6) REFERENCES tokens(value),
                                          date DATE,
                                          type VARCHAR,
                                          limits VARCHAR,
                                          result VARCHAR)')
  end

  def self.insert_patients(data, conn)
    conn.exec("INSERT INTO patients (cpf, name, email, birth_date, address, city, state) 
               VALUES ('#{data['cpf'].to_s.gsub(/[^\d]/, '')}', '#{data["nome paciente"]}', '#{data["email paciente"]}',
               '#{data["data nascimento paciente"]}', '#{data["endereço/rua paciente"]}',
               '#{data["cidade paciente"].to_s.gsub(/[\']/, '')}', '#{data["estado patiente"]}')
               ON CONFLICT DO NOTHING"
              )
  end

  def self.insert_doctors(data, conn)
    conn.exec("INSERT INTO doctors (crm, crm_state, name, email)
               VALUES ('#{data["crm médico"]}', '#{data["crm médico estado"]}', '#{data["nome médico"]}', '#{data["email médico"]}')
               ON CONFLICT DO NOTHING"
              )
  end

  def self.insert_tokens(data, conn)
    conn.exec("INSERT INTO tokens (value, id_cpf, id_crm)
               VALUES ('#{data["token resultado exame"]}', '#{data["cpf"].to_s.gsub(/[^\d]/, '')}', '#{data["crm médico"]}')
               ON CONFLICT DO NOTHING"
             )
  end

  def self.insert_exams(data, conn)
    conn.exec("INSERT INTO exams (token, date, type, limits, result)
              VALUES ('#{data["token resultado exame"]}', '#{data["data exame"]}', '#{data["tipo exame"]}',
              '#{data["limites tipo exame"]}', '#{data["resultado tipo exame"]}')
              ON CONFLICT DO NOTHING"
            )
  end

  def self.read_csv(filename, option)
    if option == "file"
      rows = CSV.read(filename, col_sep: ';')
    else
      rows = CSV.parse(filename, col_sep: ';')
    end
    columns = rows.shift
    result = rows.map do |row|
      row.each_with_object({}).with_index do |(cell, acc), idx|
        column = columns[idx]
        acc[column] = cell
      end
    end
    result
  end

end

