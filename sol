<table>
    <thead>
        <tr>
            <th>API Key</th>
            <th>Secret</th>
        </tr>
    </thead>
    <tbody>
        <tr th:each="item : ${map}">
            <td th:text="${item['API-KEY']}"></td>
            <td th:text="${item['API_KEY_SECRET']}"></td>
        </tr>
    </tbody>
</table>
