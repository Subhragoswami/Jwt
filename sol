package com.coffee.nyl.util;

import com.coffee.nyl.exceptions.CoffeeException;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.OutputStream;
import java.util.List;
import java.util.Map;
import java.util.function.Function;

@Slf4j
public class ExcelWorkBookUtil {

    public static void createExcelWorkBook(HttpServletResponse response, String fileName, List<SheetData<?>> sheetDataList) {
        Workbook workbook = new XSSFWorkbook();
        try {
            for (SheetData<?> sheetData : sheetDataList) {
                createSheet(workbook, sheetData.getSheetName(), sheetData.getHeaders(), sheetData.getData(), sheetData.getDataMapper());
            }
            writeWorkbookToResponse(response, workbook, fileName);
        } finally {
            closeWorkbook(workbook);
        }
    }

    private static <T> void createSheet(Workbook workbook, String sheetName, String[] headers, List<T> data, Function<T, List<Object>> dataMapper) {
        Sheet sheet = workbook.createSheet(sheetName);
        createHeaderRow(sheet, headers);

        int rowNum = 1;
        for (T record : data) {
            Row row = sheet.createRow(rowNum++);
            List<Object> rowData = dataMapper.apply(record);
            for (int i = 0; i < rowData.size(); i++) {
                Cell cell = row.createCell(i);
                setCellValue(cell, rowData.get(i));
            }
        }
    }

    private static void createHeaderRow(Sheet sheet, String[] headers) {
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
        }
    }

    private static void setCellValue(Cell cell, Object value) {
        if (value instanceof String) {
            cell.setCellValue((String) value);
        } else if (value instanceof Number) {
            cell.setCellValue(((Number) value).doubleValue());
        } else if (value instanceof Boolean) {
            cell.setCellValue((Boolean) value);
        } else {
            cell.setCellValue(value != null ? value.toString() : "---");
        }
    }

    private static void writeWorkbookToResponse(HttpServletResponse response, Workbook workbook, String fileName) {
        try (OutputStream outputStream = response.getOutputStream()) {
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=" + fileName + ".xlsx");
            workbook.write(outputStream);
        } catch (IOException e) {
            log.error("An error occurred while writing the Excel file: {}", e.getMessage());
            throw new CoffeeException("SYSTEM_ERROR", "Error generating Excel file.");
        }
    }

    private static void closeWorkbook(Workbook workbook) {
        try {
            if (workbook != null) {
                workbook.close();
            }
        } catch (IOException e) {
            log.error("An error occurred while closing the workbook: {}", e.getMessage());
        }
    }
}






--------------------------CSV----------------







package com.coffee.nyl.util;

import com.coffee.nyl.exceptions.CoffeeException;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.util.List;
import java.util.function.Function;

@Slf4j
public class CsvFileUtil {

    public static void createCsvFile(HttpServletResponse response, String fileName, List<SheetData<?>> sheetDataList) {
        try {
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=" + fileName + ".csv");

            try (PrintWriter writer = new PrintWriter(new OutputStreamWriter(response.getOutputStream()))) {
                for (SheetData<?> sheetData : sheetDataList) {
                    writer.println(sheetData.getSheetName()); // Write sheet name as a title
                    writeHeaders(writer, sheetData.getHeaders());
                    writeData(writer, sheetData.getData(), sheetData.getDataMapper());
                    writer.println(); // Add a blank line between sheets
                }
            }
        } catch (IOException e) {
            log.error("An error occurred while writing the CSV file: {}", e.getMessage());
            throw new CoffeeException("SYSTEM_ERROR", "Error generating CSV file.");
        }
    }

    private static void writeHeaders(PrintWriter writer, String[] headers) {
        writer.println(String.join(",", headers));
    }

    private static <T> void writeData(PrintWriter writer, List<T> data, Function<T, List<Object>> dataMapper) {
        for (T record : data) {
            List<Object> rowData = dataMapper.apply(record);
            writer.println(formatRow(rowData));
        }
    }

    private static String formatRow(List<Object> rowData) {
        StringBuilder row = new StringBuilder();
        for (int i = 0; i < rowData.size(); i++) {
            Object value = rowData.get(i);
            row.append(formatCellValue(value));
            if (i < rowData.size() - 1) {
                row.append(",");
            }
        }
        return row.toString();
    }

    private static String formatCellValue(Object value) {
        if (value == null) {
            return ""; // Empty for null values
        } else if (value instanceof String) {
            String stringValue = (String) value;
            if (stringValue.contains(",") || stringValue.contains("\"")) {
                stringValue = stringValue.replace("\"", "\"\""); // Escape quotes
                return "\"" + stringValue + "\""; // Enclose in quotes
            }
            return stringValue;
        } else {
            return value.toString();
        }
    }
}
