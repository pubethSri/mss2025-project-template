#!/bin/bash

# Define values
val1="100"
val2="200"
val3="300"

echo "
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Dynamic Cards (No JS)</title>
  <style>
    body {
      font-family: sans-serif;
      background: #f0f0f0;
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      padding: 20px;
    }
    .card {
      background: white;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      margin: 10px;
      padding: 20px;
      width: 200px;
      text-align: center;
    }
    .value {
      font-size: 2em;
      color: #333;
    }
  </style>
</head>
<body>

  <div class="card">
    <h3>Card 1</h3>
    <div class="value">$val1</div>
  </div>

  <div class="card">
    <h3>Card 2</h3>
    <div class="value">$val2</div>
  </div>

  <div class="card">
    <h3>Card 3</h3>
    <div class="value">$val3</div>
  </div>

</body>
</html>
" > japan.html
