
require 'thor'
require 'irb'

# 主要流程 修改文件名称，读取文件，读取json
class XmindBaseServiceError < StandardError; end

class CLI < Thor
  desc "console", "Start the console"
  def console
    IRB.start
  end
end

class Xmind2Json

  # 常量定义
  TEMP_FILE_PATH = Rails.root + '/tmp/'

  #
  # 初始化
  #
  #
  def initialize
  end

  #
  # xmind文件转换成JSON
  #
  # @param [File] xmind_file 文件流
  #
  # @return [JSON] 返回读取文件后的JSON字符串
  #
  def xmind_file_to_josn(xmind_file)
    # 保存临时文件
    zip_file_path = save_tem_xmind_file(xmind_file)
    # 解压zip文件
    json_file_path = unzip_file(zip_file_path)
    # 读取json文件
    xmind_json = read_file_json(json_file_path.to_s + '/content.json')
    # 删除解压zip文件夹
    delete_unzip_dir(json_file_path)
    xmind_json
  end

  #
  # 保存xmind文件临时文件
  #
  # @param [Object] xmind_file Xmind文件file对象
  #
  # @return [String] 返回xmind文件保存的路径
  #
  def save_tem_xmind_file(xmind_file)
    origin_file_name = xmind_file.original_filename
    file = File.new(xmind_file.tempfile)
    file_name = File.basename(file.path)
    file_path = Xmind::BaseService::TEMP_FILE_PATH + file_name
    File.rename(file, file_path)
    # 修改成zip文件
    file = File.open(file_path)
    file_name = File.basename(file.path)
    file_path = file_name.gsub('.xmind', '.zip')
    File.rename(file, file_name.gsub('.xmind', '.zip'))
    file_path
  end

  #
  # 读取Xmind文件
  #
  # @param [String] zip_file_path 压缩文件路径
  #
  # @return [String] 返回解压后的文件夹路径
  #
  def unzip_file(zip_file_path)
    output_dir = Xmind::BaseService::TEMP_FILE_PATH + 'xmind_flods' + "_#{@current_user.id}_#{@enterprise.id}_#{@program.id}"
    Zip::File.open(zip_file_path) do |file|
      file.each do |entry|
        entry.extract(File.join(output_dir, entry.name))
      end
    end
    File.delete(zip_file_path)
    output_dir
  end

  #
  # 读取json文件，并返回必要json数据
  #
  # @param [String]    json_file_path     json文件的路径
  #
  # @return [Json]                        返回从文件读取的json
  #
  def read_file_json(json_file_path)
    JSON.parse(File.read(json_file_path))
  end

  #
  # 删除解压缩文件目录下的所有文件
  #
  # @param [String] unzip_file_dir 需要删除的解压缩文件目录路径
  #
  #
  def delete_unzip_dir(unzip_file_dir)
    if File.directory?(unzip_file_dir)
      Dir.foreach(unzip_file_dir) do |sub_file|
        next if %w[. ..].include?(sub_file)
        delete_unzip_dir(File.join(unzip_file_dir, sub_file))
      end
      Dir.rmdir(unzip_file_dir)
    else
      File.delete(unzip_file_dir)
    end
  end

end

