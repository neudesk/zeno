# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = "BIGINT(19) UNSIGNED DEFAULT NULL auto_increment PRIMARY KEY"
admin_permission = SysUserPermission.create({
  title: "Super Admin",
  is_super_user: true
})

admin = User.create({
  title: "Admin",
  email: "admin@zenoradio.com",
  password: "password",
  permission_id: admin_permission.id,
  password_confirmation: "password",
  enabled: true
})
# For rca permission
rca_permission = SysUserPermission.create({
  title: "Rca User",
  can_manage_specific_rca_resources:true
})

# For 3rdparty permission
thirdparty_permission = SysUserPermission.create({
  title: "Thirdparty User",
  can_manage_specific_3rdparty_resources: true
})

# For broadcast permission
broadcast_permission = SysUserPermission.create({
  title: "Broadcast User",
  can_manage_specific_broadcast_resources: true
})

DataGroupCountry.create(id: 1, "iso_alpha_2" => "us", title: "US")
DataGroupCountry.create(id: 2, "iso_alpha_2" => "vn", title: "VietNam")
DataGroupCountry.create(id: 3, "iso_alpha_2" => "mx", title: "Mexico")
DataGroupCountry.create(id: 4, "iso_alpha_2" => "ca", title: "Canada")

us_language = DataGroupLanguage.create(title: "American")
vn_language = DataGroupLanguage.create(title: "VietNamese")
me_language = DataGroupLanguage.create(title: "Mexican")
ca_language = DataGroupLanguage.create(title: "Canadan")

DataGroupGenre.create(title: "Genre 1")
DataGroupGenre.create(title: "Genre 2")
DataGroupGenre.create(title: "Genre 3")
DataGroupGenre.create(title: "Genre 4")