require 'json'
require 'pg'

class Retrieve
  def self.generate_json
    @conn = PG.connect(host:'postgres', user:'postgres', password:'postgres')
    sql = 'SELECT patients.cpf AS "cpf",
                  patients.name AS "nome paciente",
                  patients.email AS "email paciente",
                  patients.birth_date AS "data nascimento paciente",
                  patients.address AS "endereço/rua paciente",
                  patients.city AS "cidade paciente",
                  patients.state AS "estado patiente",
                  doctors.crm AS "crm médico",
                  doctors.crm_state AS "crm médico estado",
                  doctors.name AS "nome médico",
                  doctors.email AS "email médico",
                  exams.token AS "token resultado exame",
                  exams.date AS "data exame",
                  exams.type AS "tipo exame",
                  exams.limits AS "limites tipo exame",
                  exams.result AS "resultado tipo exame"
                  FROM patients JOIN tokens ON cpf = id_cpf 
                  JOIN doctors on crm = id_crm 
                  JOIN exams ON value = token;'
    records = @conn.exec(sql)
    num_rows = records.num_tuples
    array = []
    for i in 0..num_rows-1
      row_hash = records[i]
      row_hash["cpf"] = row_hash["cpf"].gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4')
      array << row_hash
    end
    array.to_json
  end
end

class PatientData
  def self.generate_json
    conn = PG.connect(host:'postgres', user:'postgres', password:'postgres')
    sql = 'SELECT exams.token AS "result_token",
                  exams.date AS "result_date",
                  patients.cpf AS "cpf",
                  patients.name AS "name",
                  patients.email AS "email",
                  patients.birth_date AS "birthday",
                  doctors.crm AS "crm",
                  doctors.crm_state AS "crm_state",
                  doctors.name AS "doctors_name",
                  exams.type AS "type",
                  exams.limits AS "limits",
                  exams.result AS "result"
                  FROM patients JOIN tokens ON cpf = id_cpf 
                  JOIN doctors on crm = id_crm 
                  JOIN exams ON value = token;'
    records = conn.exec(sql)
    num_rows = records.num_tuples
    array = []
    for i in 0..num_rows-1
      row_hash = records[i]
      row_hash["cpf"] = row_hash["cpf"].gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4')
      array << row_hash
    end
    conn.close
    # p array
    self.select_info(array)
  end

  def self.select_info(array)
    result = []
    hash_token = []
    hash_token << array[0]["result_token"]
    # p array[0]["result_token"]
    temp_hash = Hash.new
    exams_hash = Hash.new
    temp_array = []
    array.each_with_index do |hash, idx|
      # p hash["result_token"]
      if hash_token.include? hash["result_token"]
        # p "entrou no if"
        temp_hash.merge!({"result_token": "#{hash['result_token']}", "result_date": "#{hash['result_date']}", "cpf": "#{hash['cpf']}", 
                          "name": "#{hash['name']}", "email": "#{hash['email']}", "birthday": "#{hash['birthday']}",
                          "doctor": {"crm": "#{hash['crm']}", "crm_state": "#{hash['crm_state']}", "name": "#{hash['doctors_name']}"}}) 
        temp_array << {"type": "#{hash['type']}", "limits": "#{hash['limits']}", "result": "#{hash['result']}"}
        hash_token << hash["result_token"]
      else
        # p "entrou no else"
        temp_hash.merge!("tests": temp_array)
        result << temp_hash
        temp_array = []
        temp_hash = Hash.new
        temp_hash.merge!({"result_token": "#{hash['result_token']}", "result_date": "#{hash['result_date']}", "cpf": "#{hash['cpf']}", 
                          "name": "#{hash['name']}", "email": "#{hash['email']}", "birthday": "#{hash['birthday']}",
                          "doctor": {"crm": "#{hash['crm']}", "crm_state": "#{hash['crm_state']}", "name": "#{hash['doctors_name']}"}})
        temp_array << {"type": "#{hash['type']}", "limits": "#{hash['limits']}", "result": "#{hash['result']}"}
        hash_token << hash["result_token"]
      end
      if idx == array.length-1
        temp_hash.merge!("tests": temp_array)
        result << temp_hash
      end
    end
    result.to_json
  end

  def self.search(token)
    conn = PG.connect(host:'postgres', user:'postgres', password:'postgres')
    sql = 'SELECT exams.token AS "result_token",
                  exams.date AS "result_date",
                  patients.cpf AS "cpf",
                  patients.name AS "name",
                  patients.email AS "email",
                  patients.birth_date AS "birthday",
                  doctors.crm AS "crm",
                  doctors.crm_state AS "crm_state",
                  doctors.name AS "doctors_name",
                  exams.type AS "type",
                  exams.limits AS "limits",
                  exams.result AS "result"
                  FROM patients JOIN tokens ON cpf = id_cpf 
                  JOIN doctors on crm = id_crm 
                  JOIN exams ON value = token
                  WHERE exams.token = $1;'
    records = conn.exec(sql, [token])
    num_rows = records.num_tuples
    array = []
    for i in 0..num_rows-1
      row_hash = records[i]
      row_hash["cpf"] = row_hash["cpf"].gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4')
      array << row_hash
    end
    self.select_info(array)
  end
end