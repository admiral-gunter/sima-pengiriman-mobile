import 'package:sima_pengiriman/shared_preferences/shared_token.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../screens/menu_select_customer/models/customer_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(path, version: 2, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS scanned_data_offline (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sn TEXT UNIQUE,
      identifier TEXT,
      tipe TEXT,
      product_name TEXT,
      date_modified DATETIME DEFAULT CURRENT_TIMESTAMP,
      date_added DATETIME DEFAULT CURRENT_TIMESTAMP,
      status TEXT,
      creator TEXT,
      lso TEXT
    );
    ''');
    //db untuk lokasi;
    await db.execute(
        '''CREATE TABLE IF NOT EXISTS inventory_location (id INTEGER PRIMARY KEY UNIQUE, text TEXT)''');
    //db untuk customer;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY,
        firstname TEXT,
        lastname TEXT,
        fullname TEXT,
        shop_name TEXT,
        phone TEXT,
        mobile TEXT,
        email TEXT,
        birth_place TEXT,
        birth_date TEXT,
        gender TEXT,
        status TEXT,
        preferences TEXT,
        newsletter TEXT,
        address TEXT,
        provinsi TEXT,
        kabupaten_kota TEXT,
        kode_pos TEXT,
        sales TEXT,
        sales_id TEXT,
        group_id INTEGER,
        user_company_id INTEGER,
        date_added DATETIME,
        date_modified DATETIME,
        address_show TEXT
      );
    ''');

    await db.execute('''CREATE TABLE inventory_validasi_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT,
        sn TEXT,
        identifier TEXT,
        location_id INT,
        customer_id INT,
        creator TEXT,
        date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status TEXT,
        lso TEXT
    )
    ''');

    await db.execute('''CREATE TABLE service_offline (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT,
        sn TEXT,
        identifier TEXT,
        location_id INT,
        customer_id INT,
        creator TEXT,
        date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status TEXT ,
        customer_nama TEXT,
        customer_notelp TEXT,
        tipe TEXT,
        tanggal_service TEXT,
        solusi TEXT
    )
    ''');

    await db.execute('''CREATE TABLE pindah_gudang_offline (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT,
        sn TEXT,
        identifier TEXT,
        location_id INT,
        customer_id INT,
        creator TEXT,
        dari_gudang TEXT,
        ke_gudang TEXT,
        in_out TEXT,
        kd_pindah_gudang TEXT,
        date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status TEXT CHECK(status IN ('unvalidasi', 'validasi')) DEFAULT 'unvalidasi' NOT NULL,
        customer_nama TEXT,
        customer_notelp TEXT,
        tipe TEXT 
    )
    ''');

    await db.execute('''CREATE TABLE grosir_out_offline (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT,
        sn TEXT,
        identifier TEXT,
        location_id INT,
        customer_id INT,
        creator TEXT,
        date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status TEXT CHECK(status IN ('unvalidasi', 'validasi')) DEFAULT 'unvalidasi' NOT NULL,
        customer_nama TEXT,
        customer_notelp TEXT
    )
    ''');

    await db.execute('''CREATE TABLE retail_out_offline (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT,
        sn TEXT,
        identifier TEXT,
        location_id INT,
        customer_id INT,
        creator TEXT,
        date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status TEXT CHECK(status IN ('unvalidasi', 'validasi')) DEFAULT 'unvalidasi' NOT NULL,
        customer_nama TEXT,
        customer_notelp TEXT
    )
    ''');

    await db.execute('''CREATE TABLE record_list_sn (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sn TEXT,
        long TEXT,
        lat TEXT,
        location_id INT,
        customer_id INT,
        creator TEXT,
        date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status TEXT CHECK(status IN ('unvalidasi', 'validasi')) DEFAULT 'unvalidasi' NOT NULL,
        customer_nama TEXT,
        customer_notelp TEXT,
        supir TEXT
    )
    ''');

    await db.execute('''CREATE TABLE record_tugas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomor_order TEXT UNIQUE,
        identifier TEXT,
        sn TEXT,
        long TEXT,
        lat TEXT,
        location_id INT,
        customer_id INT,
        creator TEXT,
        date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status TEXT ,
        customer_nama TEXT,
        customer_notelp TEXT,
        supir TEXT,
        items TEXT,
        qty_sum TEXT
    )
    ''');

    await db.execute('''CREATE TABLE record_tugas_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomor_order_surat_jalan TEXT,
        status_id INTEGER,
        status_nama TEXT,
        keterangan TEXT,
        date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    ''');

    await db.execute('''CREATE TABLE barang_turun_tap (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomor_order TEXT,
        sn TEXT UNIQUE,
        identifier TEXT,
        product_name TEXT,
        long TEXT,
        lat TEXT,
        location_id INT,
        customer_id INT,
        creator TEXT,
        date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status TEXT ,
        customer_nama TEXT,
        customer_notelp TEXT,
        supir TEXT,
        tapper TEXT
    )
    ''');

    await db.execute('''CREATE TABLE history_tugas_surat_jalan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomor_order TEXT UNIQUE,
        nama_toko TEXT,
        creator TEXT,
        date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        date_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status TEXT,
        customer_nama TEXT,
        customer_notelp TEXT,
        supir TEXT,
        tapper TEXT
    )
    ''');

    await db.execute('''CREATE TABLE assigned_customer (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fullname TEXT,
      shop_name TEXT UNIQUE,
      sale_wholesale_customer_id INTEGER,
      supir_id INTEGER,
      nama_supir TEXT
    )
    ''');

    await db.execute('''CREATE TABLE nomor_sj (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_toko INTEGER,
        nomor_sj TEXT UNIQUE
    )
    ''');
  }

  Future<String> insertNomorSj(
      Database db, String idToko, String nomorSj) async {
    try {
      await db.insert(
        'nomor_sj',
        {
          'id_toko': idToko,
          'nomor_sj': nomorSj,
        },
        conflictAlgorithm:
            ConflictAlgorithm.ignore, // Ignore if there's a duplicate
      );
      return 'Insert successful';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> insertAssignedCustomer(String fullname, String shopName,
      int saleWholesaleCustomerId, int supirId, String namaSupir) async {
    try {
      final Database db = await instance.database;

      await db.insert(
        'assigned_customer',
        {
          'fullname': fullname,
          'shop_name': shopName,
          'sale_wholesale_customer_id': saleWholesaleCustomerId,
          'supir_id': supirId,
          'nama_supir': namaSupir,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore duplicates
      );
      return 'SUKSES';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<List<Customer>> getAssignedCustomers() async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('assigned_customer');
    return List.generate(maps.length, (i) {
      return Customer(
        id: maps[i]['id'].toString(),
        fullname: maps[i]['fullname'],
        shopName: maps[i]['shop_name'],
        saleWholesaleCustomerId:
            maps[i]['sale_wholesale_customer_id'].toString(),
        supirId: maps[i]['supir_id'].toString(),
        namaSupir: maps[i]['nama_supir'],
      );
    });
  }

  Future<List<dynamic>> getDataTapForToday() async {
    final Database db = await instance.database;
    String today = DateTime.now().toLocal().toString().substring(0, 10);

    final List<Map<String, dynamic>> maps = await db.query(
      'barang_turun_tap',
      where: 'date_added LIKE ?',
      whereArgs: ['$today%'],
    );

    return maps;
  }

  Future<Map<String, dynamic>> insertHistorySuratJalan(
      Map<String, dynamic> data) async {
    final db = await instance.database;
    try {
      await db.insert('history_tugas_surat_jalan', data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
      return {'result': true, 'message': 'Data inserted successfully.'};
    } catch (e) {
      print('Failed to insert data: $e');
      return {'result': false, 'message': 'Failed to insert data: $e'};
    }
  }

  Future<Map<String, dynamic>> insertHistorySuratJalanBatal(
      Map<String, dynamic> data) async {
    final db = await instance.database;
    try {
      final dataInsert = {
        "nomor_order": data['no_surat_jalan'],
        "nama_toko": "NONE",
        "creator": data['creator'],
        "status": 'pending_batal_kirim',
        "supir": data['creator'],
        "tapper": data['creator']
      };

      await db.insert('history_tugas_surat_jalan', dataInsert);
      return {'result': true, 'message': 'Data inserted successfully.'};
    } catch (e) {
      print('Failed to insert data: $e');
      return {'result': false, 'message': 'Failed to insert data: $e'};
    }
  }

  Future<List<Map<String, dynamic>>> getHistorySuratJalan() async {
    final db = await instance.database;
    return await db.query('history_tugas_surat_jalan',
        orderBy: 'date_added DESC');
  }

  Future<List<Map<String, dynamic>>> getRecordTugasDT() async {
    final db = await instance.database;
    return await db.query(
      'record_tugas',
      columns: [
        'nomor_order',
      ], // Replace with the actual column names you want
      orderBy: 'date_added DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getRecordTugasDT2(
      [String? noOrder]) async {
    final db = await instance.database;

    String query = '''
    SELECT
        record_tugas.*,
        record_tugas_history.status_id,
        record_tugas_history.status_nama,
        record_tugas_history.keterangan
    FROM
        record_tugas
    LEFT JOIN
        history_tugas_surat_jalan
        ON record_tugas.nomor_order = history_tugas_surat_jalan.nomor_order
    LEFT JOIN
        record_tugas_history
        ON record_tugas_history.nomor_order_surat_jalan = record_tugas.nomor_order
        AND record_tugas_history.date_added = (
            SELECT MAX(date_added)
            FROM record_tugas_history
            WHERE nomor_order_surat_jalan = record_tugas.nomor_order
        )
    WHERE
        history_tugas_surat_jalan.nomor_order IS NULL
  ''';

    if (noOrder != null && noOrder.isNotEmpty) {
      query += '''
      AND record_tugas_history.nomor_order_surat_jalan LIKE '%${noOrder}%'
    ''';
    }

    query += '''
    ORDER BY
        record_tugas.date_added DESC
  ''';

    return await db.rawQuery(query);
  }

  Future<List<Map<String, dynamic>>> getBarangTurunDT() async {
    final db = await instance.database;

    // var result = await db.query('barang_turun_tap');
    final username = await SharedToken.univGetterString('username');
    return await db.query(
      'barang_turun_tap',
      distinct: true,
      columns: [
        'sn',
      ],
      orderBy: 'date_added DESC',
      where: 'creator = ? ',
      whereArgs: [username],
    );
  }

  Future<List<Map<String, dynamic>>> getRecordTugas() async {
    final db = await instance.database;
    List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT * FROM record_tugas GROUP BY nomor_order');

    return result;
  }

  Future<void> deleteRecordTugasByNomorOrder(String noOrder) async {
    try {
      final db = await instance.database;

      await db.delete(
        'record_tugas',
        where: 'nomor_order = ?',
        whereArgs: [noOrder],
      );
    } catch (e) {
      print('deleteRecordTugas ERROR: $e');
      // throw Exception('Error deleting records: $e');
    }
  }

  Future<bool> doesDataExistPerItemTap(
      dynamic nomorOrder, dynamic inventoryId) async {
    final db = await instance.database;

    var result = await db.query(
      'barang_turun_tap',
      where: 'nomor_order LIKE ? AND sn LIKE ?',
      whereArgs: [
        '%$nomorOrder%',
        '%$inventoryId%'
      ], // Using % to match any characters before or after nomorOrder and inventoryId
    );
    return result.isNotEmpty;
  }

  Future<int> countBarangTap(String productName, String orderNumber) async {
    final db = await instance.database;

    // Execute the query
    List<Map<String, dynamic>> result = await db.query('barang_turun_tap',
        columns: ['COUNT(*)'],
        where: 'product_name = ? AND nomor_order = ?',
        whereArgs: [productName, orderNumber]);

    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  Future<List<Map<String, dynamic>>> getAllBarangTap(
      String productName, String orderNumber, String inventoryId) async {
    final db = await instance.database;

    // Execute the query to get all rows
    List<Map<String, dynamic>> result = await db.query('barang_turun_tap',
        distinct: true,
        where: 'product_name = ? AND nomor_order = ? AND sn = ?',
        whereArgs: [productName, orderNumber, inventoryId]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllDataFromTable() async {
    final db = await instance.database;

    var result = await db.query('barang_turun_tap');
    return result;
  }

  Future<Map<String, dynamic>> insertBarangTurun(
      Map<String, dynamic> data) async {
    final db = await instance.database;
    try {
      data.remove('no_plat');
      await db.insert('barang_turun_tap', data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
      return {'result': true, 'message': 'Data inserted successfully.'};
    } catch (e) {
      print('Failed to insert data: $e');
      return {'result': false, 'message': 'Failed to insert data: $e'};
    }
  }

  Future<bool> doesDataExistBarangTurun(String sn) async {
    final db = await instance.database;

    String whereClause = 'sn = ?';
    List<dynamic> whereArgs = [sn];

    List<Map<String, dynamic>> result = await db.query(
      'barang_turun_tap',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>> insertRecordTugas(
      Map<String, dynamic> data) async {
    final db = await instance.database;
    try {
      await db.insert('record_tugas', data);
      return {'result': true, 'message': 'Data inserted successfully.'};
    } catch (e) {
      return {'result': false, 'message': 'Failed to insert data: $e'};
    }
  }

  Future<Map<String, dynamic>> insertRecordTugasHistory(
      Map<String, dynamic> data) async {
    final db = await instance.database;

    try {
      await db.insert('record_tugas_history', data);
      return {'result': true, 'message': 'Data inserted successfully.'};
    } catch (e) {
      return {'result': false, 'message': 'Failed to insert data: $e'};
    }
  }

  Future<dynamic> getRecordTugasHistory() async {
    final db = await instance.database;

    try {
      return await db.query('record_tugas_history');
      // return {'result': true, 'message': 'Data inserted successfully.'};
    } catch (e) {
      print(e);
    }
  }

  Future<List<Map<String, dynamic>>> getRetailOut() async {
    final db = await instance.database;
    return await db.query('retail_out_offline');
  }

  Future<List<Map<String, dynamic>>> getGrosirOut() async {
    final db = await instance.database;
    return await db.query('grosir_out_offline');
  }

  Future<Map<String, dynamic>> insertGrosirTapOut(
      Map<String, dynamic> data) async {
    final db = await instance.database;
    try {
      await db.insert('grosir_out_offline', data);
      return {'result': true, 'message': 'Data inserted successfully.'};
    } catch (e) {
      return {'result': false, 'message': 'Failed to insert data: $e'};
    }
  }

  Future<Map<String, dynamic>> insertRetailTapOut(
      Map<String, dynamic> data) async {
    final db = await instance.database;
    try {
      await db.insert('retail_out_offline', data);
      return {'result': true, 'message': 'Data inserted successfully.'};
    } catch (e) {
      return {'result': false, 'message': 'Failed to insert data: $e'};
    }
  }

  Future<void> insertDatainventoryLocation(List<dynamic> data) async {
    final db = await instance.database;
    for (final item in data) {
      await db.insert('inventory_location', item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<Map<String, dynamic>> insertInventoryValidasiHistory(
      Map<String, dynamic> data) async {
    final db = await instance.database;
    try {
      await db.insert('inventory_validasi_history', data);
      return {'result': true, 'message': 'Data inserted successfully.'};
    } catch (e) {
      return {'result': false, 'message': 'Failed to insert data: $e'};
    }
  }

  Future<Map<String, dynamic>> insertServiceOffline(data) async {
    final db = await instance.database;
    try {
      Map<String, dynamic> map = {};

      data.forEach((key, value) {
        if (key is String) {
          map[key] = value;
        }
      });

      await db.insert('service_offline', map);
      return {'result': true, 'message': 'Data inserted successfully.'};
    } catch (e) {
      return {'result': false, 'message': 'Failed to insert data: $e'};
    }
  }

  Future<List<dynamic>> getDataService() async {
    final db = await instance.database;
    return await db.query('service_offline');
  }

  Future insertPindahGudangOffline(data) async {
    final db = await instance.database;
    try {
      Map<String, dynamic> map = {};

      data.forEach((key, value) {
        if (key is String) {
          map[key] = value;
        }
      });

      await db.insert('pindah_gudang_offline', map);
      return {'result': true, 'message': 'Data inserted successfully.'};
    } catch (e) {
      return {'result': false, 'message': 'Failed to insert data: $e'};
    }
  }

  Future<List<dynamic>> getDataPindahGudang() async {
    final db = await instance.database;
    return await db.query('pindah_gudang_offline');
  }

  Future<List<Map<String, dynamic>>> getDataInvHistory() async {
    final db = await instance.database;
    return await db.query('inventory_validasi_history');
  }

  Future<void> insertDataCustomer(List<dynamic> data) async {
    final db = await instance.database;
    for (final item in data) {
      // print(data);
      await db.insert('customers', item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Map<String, dynamic>>> getData() async {
    final db = await instance.database;
    return await db.query('inventory_location');
  }

  Future<List<Map<String, dynamic>>> getInventoryLocations() async {
    final db = await instance.database;
    return await db.query('inventory_location');
  }

  Future<List<Map<String, dynamic>>> getCustomers() async {
    final db = await instance.database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      '''SELECT id, firstname || ' ' || lastname || ' ( ' || shop_name || ' ) ' || ' ' || phone AS name FROM customers''',
    );

    return result;
  }

  void dropDatabase() async {
    String databasePath = join(await getDatabasesPath(), 'my_database.db');

    await deleteDatabase(databasePath);
  }

  Future<void> emptyAllTables() async {
    final db = await database;
    final tables = [
      'barang_turun_tap',
      'record_tugas',
      'history_tugas_surat_jalan'
    ];

    for (final table in tables) {
      final tableName = table as String;
      await db.rawDelete('DELETE FROM $tableName');
    }
  }
}
