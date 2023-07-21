require 'csv'
require 'pg'

@conn = PG.connect(host:'postgres', user:'postgres')

# result = conn.exec('COMANDO SQL')

rows = CSV.read("./data.csv", col_sep: ';')

columns = rows.shift

hash_data = rows.map do |row|
  row.each_with_object({}).with_index do |(cell, acc), idx|
    column = columns[idx]
    acc[column] = cell
  end
end

# p hash_data[0]['cpf']
# p hash_data[1]['cpf']

@conn.exec('CREATE TABLE IF NOT EXISTS patients (cpf VARCHAR(11) PRIMARY KEY, name VARCHAR(60), email VARCHAR(60), birth_date DATE, address VARCHAR(60), city VARCHAR(30), state VARCHAR(30));')
@conn.exec('CREATE TABLE IF NOT EXISTS doctors (crm VARCHAR(10) PRIMARY KEY, crm_state VARCHAR(30), name VARCHAR(60), email VARCHAR(60));')
@conn.exec('CREATE TABLE IF NOT EXISTS tokens (value VARCHAR(6) PRIMARY KEY, id_cpf VARCHAR(11) REFERENCES patients(cpf), id_crm VARCHAR(10) REFERENCES doctors(crm))')
@conn.exec('CREATE TABLE IF NOT EXISTS exams (token VARCHAR(6) REFERENCES tokens(value), date DATE, type VARCHAR(30), limits VARCHAR(30), result VARCHAR(30))')

# def pacientes(hash_data)
#   tmp_cpf = ''
#   cpf_array = []
#   hash_data.each do |data|
#     if !cpf_array.include? data['cpf']
#       p data['cpf'].to_s.gsub(/[^\d]/, '')
#       p data["nome paciente"]
#       p data["email paciente"]
#       p data["data nascimento paciente"]
#       p data["endereço/rua paciente"]
#       p data["cidade paciente"]
#       p data["estado patiente"]
#     end
#     cpf_array << data['cpf']
#   end
# end

def insert_patients(hash_data)
  tmp_cpf = ''
  cpf_array = []
  hash_data.each do |data|
    if !cpf_array.include? data['cpf']
      @conn.exec("INSERT INTO patients (cpf, name, email, birth_date, address, city, state) 
                  VALUES ('#{data['cpf'].to_s.gsub(/[^\d]/, '')}', '#{data["nome paciente"]}', '#{data["email paciente"]}',
                  '#{data["data nascimento paciente"]}', '#{data["endereço/rua paciente"]}',
                  '#{data["cidade paciente"].to_s.gsub(/[\']/, '')}', '#{data["estado patiente"]}')"
                )
    end
    cpf_array << data['cpf']
  end
end

def insert_doctors(hash_data)
  tmp_crm = ''
  crm_array = []
  hash_data.each do |data|
    if !crm_array.include? data['crm médico']
      @conn.exec("INSERT INTO doctors (crm, crm_state, name, email)
                  VALUES ('#{data["crm médico"]}', '#{data["crm médico estado"]}', '#{data["nome médico"]}', '#{data["email médico"]}')")
    end
    crm_array << data['crm médico']
  end
end

def insert_tokens(hash_data)
  tmp_token = ''
  token_array = []
  hash_data.each do |data|
    if !token_array.include? data['token resultado exame']
      @conn.exec("INSERT INTO tokens (value, id_cpf, id_crm)
                  VALUES ('#{data["token resultado exame"]}', '#{data["cpf"].to_s.gsub(/[^\d]/, '')}', '#{data["crm médico"]}')")
    end
    token_array << data['token resultado exame']
  end
end

def insert_exams(hash_data)
  hash_data.each do |data|
    @conn.exec("INSERT INTO exams (token, date, type, limits, result)
                VALUES ('#{data["token resultado exame"]}', '#{data["data exame"]}', '#{data["tipo exame"]}',
                '#{data["limites tipo exame"]}', '#{data["resultado tipo exame"]}')")
  end
end

insert_patients(hash_data)
insert_doctors(hash_data)
insert_tokens(hash_data)
insert_exams(hash_data)