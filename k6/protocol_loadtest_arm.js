// import { browser } from 'k6/experimental/browser';
// import { check } from 'k6';
import http from 'k6/http';
import { sleep, group } from 'k6'

export const options = {
  scenarios: {
    frontend: {
      executor: 'ramping-arrival-rate',
      preAllocatedVUs: 100,
      stages: [
        { target: 2000, duration: '15m' },
      ],
      exec: 'browserTest',
    }
  },
  insecureSkipTLSVerify: true
};

export async function browserTest() {
  let response

  group('page_2 - http://supremorentalsarm.oracledemo.online/cardetails/t001', function () {
    response = http.get('http://140.238.167.80:5000/car-service-redis/cars/t001')
    response = http.get('http://140.238.167.80:5000/order-service/user-orders?userid=JohnC')
    response = http.get('http://140.238.167.80:5000/user-service-redis/users/JohnC')
    response = http.get('http://140.238.167.80:5000/order-service/user-orders?userid=JohnC')
    response = http.get('http://140.238.167.80:5000/order-service/user-orders?userid=JohnC')
    sleep(1.8)
  })

  group('page_3 - http://supremorentalsarm.oracledemo.online/carcheckout/t001', function () {
    response = http.get('http://140.238.167.80:5000/car-service-redis/cars/t001')

    response = http.get('http://140.238.167.80:5000/order-service/user-orders?userid=JohnC')

    response = http.get('http://140.238.167.80:5000/user-service-redis/users/JohnC')

    response = http.get('http://140.238.167.80:5000/user-service-redis/users/JohnC')

    response = http.get('http://140.238.167.80:5000/order-service/user-orders?userid=JohnC')

    response = http.get('http://140.238.167.80:5000/order-service/user-orders?userid=JohnC')

    response = http.get('http://140.238.167.80:5000/order-service/user-orders?userid=JohnC')

    response = http.get('http://140.238.167.80:5000/order-service/user-orders?userid=JohnC')
    sleep(1.1)

    response = http.post(
      'http://140.238.167.80:5000/order-service/create-order',
      '{"userid":"JohnC","carid":"t001","brand":"Toyoto","name":"Corolla","from_date":"2024-02-29","end_date":"2024-03-01","duration":1,"ordered":"TRUE"}',
      {
        headers: {
          'content-type': 'application/json',
        },
      }
    )

    response = http.options('http://140.238.167.80:5000/order-service/create-order', null, {
      headers: {
        accept: '*/*',
        'access-control-request-headers': 'content-type',
        'access-control-request-method': 'POST',
        origin: 'http://supremorentalsarm.oracledemo.online',
        'sec-fetch-mode': 'cors',
      },
    })
  })

  group('page_4 - http://supremorentalsarm.oracledemo.online/confirmbooking/t001', function () {
    response = http.get('http://140.238.167.80:5000/car-service-redis/cars/t001')
    response = http.get('http://140.238.167.80:5000/user-service-redis/users/JohnC')
    response = http.get('http://140.238.167.80:5000/order-service/user-orders?userid=JohnC')
  })
}