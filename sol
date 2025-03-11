<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>API Credentials</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
        }
        .container {
            max-width: 600px;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
            box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #0033a0;
        }
        .important {
            font-weight: bold;
            color: red;
        }
        .logo {
            text-align: right;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="logo">
        <img src="/images/sbi-epay-logo.png" alt="SBI ePay Logo" width="120">
    </div>
    
    <h1>API Credentials</h1>
    
    <p>Thank you for using <strong>SBI ePay Merchant Portal</strong>. This document contains important details for accessing the <strong>SBI ePay</strong> APIs securely.</p>

    <h2>API Credentials</h2>
    <ul>
        <li><strong>API Key ID:</strong> <span th:text="${apiKeyId}">__________</span></li>
        <li><strong>API Key Secret:</strong> <span th:text="${apiKeySecret}">__________</span></li>
    </ul>

    <p class="important">Important: Keep your API credentials confidential. Do not share them publicly, and store them in a secure location. The API Key Secret should never be exposed in your code or in public-facing systems.</p>
</div>

</body>
</html>
