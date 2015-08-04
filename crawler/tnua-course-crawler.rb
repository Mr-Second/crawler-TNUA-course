require 'crawler_rocks'
require 'json'
require 'pry'

class TaipeiNationalUniversityOfTheArtsCrawler

	def initialize year: nil, term: nil, update_progress: nil, after_each: nil

		@year = year-1911
		@term = term
		@update_progress_proc = update_progress
		@after_each_proc = after_each

		@query_url = 'http://203.71.172.85/Public/Public.aspx'
	end

	def courses
		@courses = []

		r = RestClient.get(@query_url)
		doc = Nokogiri::HTML(r)

		hidden = Hash[doc.css('input[type="hidden"]').map{|hidden| [hidden[:name], hidden[:value]]}]

		dep = Hash[doc.css('select[name="PublicAcx1$CourseQueryAcxTNUA1$ddl_Dept"] option:nth-child(n+2)').map{|opt| [opt[:value], opt.text]}]
		dep.each do |dep_c, dep_n|

			r = RestClient.post(@query_url, {
				"ScriptManager1" => "PublicAcx1$CourseQueryAcxTNUA1$UpdatePanel3|PublicAcx1$CourseQueryAcxTNUA1$ddl_Dept",
				"__EVENTTARGET" => "PublicAcx1$CourseQueryAcxTNUA1$ddl_Dept",
				# "__EVENTARGUMENT" => "",
				# "__LASTFOCUS" => "",
				"__VIEWSTATE" => hidden["__VIEWSTATE"],
				"__VIEWSTATEENCRYPTED" => "",
				"PublicAcx1$CourseQueryAcxTNUA1$ddlYear" => @year,
				"PublicAcx1$CourseQueryAcxTNUA1$ddl_Semi" => @term,
				"PublicAcx1$CourseQueryAcxTNUA1$ddl_Dept" => dep_c,
				"PublicAcx1$CourseQueryAcxTNUA1$ddCredit" => "-1",
				"PublicAcx1$CourseQueryAcxTNUA1$ddYearCos" => "0",
				"PublicAcx1$CourseQueryAcxTNUA1$ddWeek" => "0",
				"PublicAcx1$CourseQueryAcxTNUA1$ddSSect" => "0",
				"PublicAcx1$CourseQueryAcxTNUA1$ddESect" => "999",
				# "PublicAcx1$CourseQueryAcxTNUA1$edtTitle" => "",
				# "PublicAcx1$CourseQueryAcxTNUA1$edtName" => "",
				"PublicAcx1$CourseQueryAcxTNUA1$ddSort" => "2",
				"__ASYNCPOST" => "true",
				"" => "",
				}, {"User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/43.0.2357.130 Chrome/43.0.2357.130 Safari/537.36"})

			hidden = Hash[r.split('hiddenField')[1..-1].map{|hidden| [hidden.split('|')[1], hidden.split('|')[2]]}]

			r = RestClient.post(@query_url, {
				"ScriptManager1" => "PublicAcx1$CourseQueryAcxTNUA1$UpdatePanel6|PublicAcx1$CourseQueryAcxTNUA1$LB_Query",
				"__EVENTTARGET" => "PublicAcx1$CourseQueryAcxTNUA1$LB_Query",
				# "__EVENTARGUMENT" => "",
				# "__LASTFOCUS" => "",
				"__VIEWSTATE" => hidden["__VIEWSTATE"],
				"__VIEWSTATEENCRYPTED" => "",
				"PublicAcx1$CourseQueryAcxTNUA1$ddlYear" => @year,
				"PublicAcx1$CourseQueryAcxTNUA1$ddl_Semi" => @term,
				"PublicAcx1$CourseQueryAcxTNUA1$ddl_Dept" => dep_c,
				"PublicAcx1$CourseQueryAcxTNUA1$ddCredit" => "-1",
				"PublicAcx1$CourseQueryAcxTNUA1$ddYearCos" => "0",
				"PublicAcx1$CourseQueryAcxTNUA1$ddWeek" => "0",
				"PublicAcx1$CourseQueryAcxTNUA1$ddSSect" => "0",
				"PublicAcx1$CourseQueryAcxTNUA1$ddESect" => "999",
				# "PublicAcx1$CourseQueryAcxTNUA1$edtTitle" => "",
				# "PublicAcx1$CourseQueryAcxTNUA1$edtName" => "",
				"PublicAcx1$CourseQueryAcxTNUA1$ddSort" => "2",
				"__ASYNCPOST" => "true",
				"" => "",
				}, {"User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/43.0.2357.130 Chrome/43.0.2357.130 Safari/537.36"})
			doc = Nokogiri::HTML(r)

			doc.css('table[id="PublicAcx1_CourseQueryAcxTNUA1_GridView1"] tr:nth-child(n+2)').map{|tr| tr}.each do |tr|
				data = tr.css('td').map{|td| td.text}

				course = {
					year: @year,
					term: @term,
					general_code: data[0],    # 課程代號
					name: data[1],    # 課程名稱
					department_type: data[2],    # 班別
					required: data[3],    # 修別(必選修)
					credits: data[4],   # 學分數
					department_term: data[5],    # 學期別
					lecturer: data[6],    # 授課教師
					day: data[7],   # 上課時間格式: (三)1,2
					location: data[8],    # 教室代號
					course_type: data[9],    # 課程領域
					people_maximum: data[10],    # 人數上限
					people: data[11],    # 已選人數
					for_who: data[12],    # 選課對象
					notes: data[13],    # 備註說明
					}

				@after_each_proc.call(course: course) if @after_each_proc

				@courses << course
			end
		end
	# binding.pry
			@courses
	end
end

# crawler = TaipeiNationalUniversityOfTheArtsCrawler.new(year: 2015, term: 1)
# File.write('courses.json', JSON.pretty_generate(crawler.courses()))
