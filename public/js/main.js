const fragment = new DocumentFragment();
const tbody = document.createElement('tbody')
const tbody1 = document.createElement('tbody')
const tbody2 = document.createElement('tbody')
let table = document.querySelector('tbody#main');
var url = 'http://0.0.0.0:3000/tests/fmt=json';

function getInfo(url, details) {
  fetch(url).
    then((response) => response.json()).
    then((data) => {
      if (data.result === "none") {
        details = 0;
        document.getElementById('goBack').style.display = "initial";
        document.getElementById('noResults').style.display = "initial";
      }else{
        document.getElementById('noResults').style.display = "none";

        data.forEach(function(exam) {
          // const patientData = { cpf: exam.cpf, name: exam.name, doctor: exam.doctor.name };
          // const examData = {result_token: exam.result_token, result_date: exam.result_date};
          const tr = document.createElement('tr');
          
          tr.innerHTML += `
                          <td>${exam.result_token}</td>
                          <td>${new Date(exam.result_date).toLocaleDateString('pt-BR', {timeZone: 'UTC'})}</td>
                          <td>${exam.cpf}</td>
                          <td>${exam.name}</td>
                          <td>${new Date(exam.birthday).toLocaleDateString('pt-BR', {timeZone: 'UTC'})}</td>
                          <td>${exam.doctor.name}</td>
                        `
          const button = document.createElement('button');
          button.innerHTML = `Detalhes`;
          button.classList = 'btn btn-sm btn_details'
          button.setAttribute('id', `${exam.result_token}`)
          button.addEventListener('click', function() {
            table.innerHTML = ''
            let queryPath = `http://0.0.0.0:3000/tests/${exam.result_token}`
            getInfo(queryPath);
            getExamDetails(queryPath);
            button.style.display = "none";
          })
          tdBtn = document.createElement('td');
          tdBtn.appendChild(button);  
          tr.appendChild(tdBtn);
          fragment.appendChild(tr);
        })
      }
    }).
    then(() => {
      table.appendChild(fragment);
      if (details === 1) {
        getExamDetails(url)
      }
    }).
    catch(function(err) {
      console.log("erro", err);
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
                         <td>${data.type}</td>
                         <td>${data.limits}</td>
                         <td>${data.result}</td>
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
    getInfo(queryPath, 1);
  }else{
    table.innerHTML = ''
    getInfo(url, 0)
    document.getElementById('details').style.display = "none"
  }
}

function goBack() {
  table.innerHTML = ''
  getInfo(url, 0)
  document.getElementById('goBack').style.display = "none"
  document.getElementById('details').style.display = "none"
  document.getElementById('noResults').style.display = "none";
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
      getInfo(url, 0);
    }, 15000);
  }).
  catch(function(err) {
    console.log(err);
  });
}

var GET = {};
var query = window.location.search.substring(1).split("&");
for (var i = 0, max = query.length; i < max; i++)
{
    if (query[i] === "")
        continue;

    var param = query[i].split("=");
    GET[decodeURIComponent(param[0])] = decodeURIComponent(param[1] || "");
}

if (GET.env === 'test') {
  url = 'http://rebase-labs:3000/tests/fmt=json';
}else{
  url = 'http://0.0.0.0:3000/tests/fmt=json';
}

window.onload = getInfo(url, 0);