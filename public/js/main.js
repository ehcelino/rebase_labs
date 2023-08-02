const fragment = new DocumentFragment();
const tbody = document.createElement('tbody')
const tbody1 = document.createElement('tbody')
const tbody2 = document.createElement('tbody')
let table = document.querySelector('tbody#main');
const url = 'http://0.0.0.0:3000/tests/fmt=json';

function getInfo(url) {
  let htmlData = '';
  fetch(url).
    then((response) => response.json()).
    then((data) => {
      data.forEach(function(exam) {
        const patientData = { cpf: exam.cpf, name: exam.name, doctor: exam.doctor.name };
        const examData = {result_token: exam.result_token, result_date: exam.result_date};
        const tr = document.createElement('tr');
        
        tr.innerHTML += `
                         <td>${exam['result_token']}</td>
                         <td>${exam['result_date']}</td>
                         <td>${exam['cpf']}</td>
                         <td>${exam['name']}</td>
                         <td>${exam['doctor']['name']}</td>
                       `
        const button = document.createElement('button');
        button.innerHTML = `Detalhes`;
        button.classList = 'btn btn-sm btn_details'
        button.setAttribute('id', `${exam['result_token']}`)
        button.addEventListener('click', function() {
          table.innerHTML = ''
          let queryPath = `http://0.0.0.0:3000/tests/${exam['result_token']}`
          getInfo(queryPath);
          getExamDetails(queryPath);
          button.style.display = "none";
        })
        tdBtn = document.createElement('td');
        tdBtn.appendChild(button);  
        tr.appendChild(tdBtn);
        fragment.appendChild(tr);
      })
    }).
    then(() => {
      table.appendChild(fragment);
    }).
    catch(function(err) {
      console.log(err);
    });
}

function getExamDetails(url) {
  fetch(url).
    then((response) => response.json()).
    then((data) => {
      data.forEach(function(exam) {
        const examDetails = exam.tests
        let htmlData = ''
        
        tbody1.innerHTML = `<tr>
                              <td>${exam.doctor.crm}</td>
                              <td>${exam.doctor.crm_state}</td>
                            </tr>`

        examDetails.forEach(data => {
          htmlData += `<tr>
                         <td>${data['type']}</td>
                         <td>${data['limits']}</td>
                         <td>${data['result']}</td>
                       </tr>`
        });
        tbody.innerHTML = htmlData;
      })
    }).
    then(() => {
      document.getElementById('details').style.display = "initial"
      document.querySelector('table#doctorDetails').appendChild(tbody1);
      document.querySelector('table#results').appendChild(tbody);
      document.querySelector('button.btn_details').style.display = "none";
      document.getElementById('goBack').style.display = "initial";
    }).
    catch(function(err) {
      console.log(err);
    });
}

function searchForm() {
  let query = document.querySelector('input#search').value.toUpperCase();
  if(query != ''){
    table.innerHTML = ''
    let queryPath = `http://0.0.0.0:3000/tests/${query}`
    getInfo(queryPath);
    getExamDetails(queryPath);
  }else{
    table.innerHTML = ''
    getInfo(url)
    document.getElementById('details').style.display = "none"
  }
}

function goBack() {
  table.innerHTML = ''
  getInfo(url)
  document.getElementById('goBack').style.display = "none"
  document.getElementById('details').style.display = "none"
}

async function loadFile(event){
  document.getElementById('waitMessage').style.display = "initial"
  const file = event.target.files.item(0)
  const fileBody = await file.text();
  await fetch(`http://0.0.0.0:3000/import`, {
    method: 'POST',
    body: `${fileBody}`
  }).
  then(() => {
    setTimeout(() => {
      document.getElementById('waitMessage').style.display = "none"
      getInfo(url);
    }, 15000);
  }).
  catch(function(err) {
    console.log(err);
  });
}

window.onload = getInfo(url);