using System;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace BadmintonClubApp
{
    public partial class MainForm : Form
    {
        private string connectionString = "Server=localhost;Database=BadmintonClubDB;Integrated Security=true;";
        private TabControl mainTabControl;

        public MainForm()
        {
            InitializeComponent();
        }

        private void InitializeComponent()
        {
            this.Text = "Quản Lý Câu Lạc Bộ Cầu Lông";
            this.Size = new System.Drawing.Size(1200, 800);
            this.StartPosition = FormStartPosition.CenterScreen;

            mainTabControl = new TabControl();
            mainTabControl.Dock = DockStyle.Fill;

            // Tạo các tab
            CreateMembersTab();
            CreateCourtsTab();
            CreateCoachesTab();
            CreateBookingsTab();
            CreatePaymentsTab();
            CreateReportsTab();

            this.Controls.Add(mainTabControl);
        }

        #region Members Tab
        private void CreateMembersTab()
        {
            TabPage tab = new TabPage("Hội Viên");
            
            DataGridView dgv = new DataGridView();
            dgv.Dock = DockStyle.Fill;
            dgv.Name = "dgvMembers";
            dgv.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgv.CellClick += DgvMembers_CellClick;

            Panel panel = new Panel();
            panel.Dock = DockStyle.Top;
            panel.Height = 150;

            // Controls
            Label lblTitle = new Label { Text = "QUẢN LÝ HỘI VIÊN", Font = new System.Drawing.Font("Arial", 14, System.Drawing.FontStyle.Bold), Location = new System.Drawing.Point(10, 10), AutoSize = true };
            
            Label lblName = new Label { Text = "Tên:", Location = new System.Drawing.Point(10, 40), AutoSize = true };
            TextBox txtName = new TextBox { Name = "txtName", Location = new System.Drawing.Point(60, 37), Width = 200 };

            Label lblDOB = new Label { Text = "NS:", Location = new System.Drawing.Point(280, 40), AutoSize = true };
            DateTimePicker dtpDOB = new DateTimePicker { Name = "dtpDOB", Location = new System.Drawing.Point(310, 37), Width = 150 };

            Label lblGender = new Label { Text = "GT:", Location = new System.Drawing.Point(10, 70), AutoSize = true };
            ComboBox cbGender = new ComboBox { Name = "cbGender", Location = new System.Drawing.Point(60, 67), Width = 100 };
            cbGender.Items.AddRange(new object[] { "Nam", "Nữ" });

            Label lblPhone = new Label { Text = "SĐT:", Location = new System.Drawing.Point(180, 70), AutoSize = true };
            TextBox txtPhone = new TextBox { Name = "txtPhone", Location = new System.Drawing.Point(220, 67), Width = 150 };

            Label lblType = new Label { Text = "Loại:", Location = new System.Drawing.Point(10, 100), AutoSize = true };
            ComboBox cbType = new ComboBox { Name = "cbType", Location = new System.Drawing.Point(60, 97), Width = 150 };
            cbType.Items.AddRange(new object[] { "Tháng", "Năm", "Vãng lai" });

            Button btnAdd = new Button { Text = "Thêm", Location = new System.Drawing.Point(400, 40), Width = 80, Name = "btnAddMember", BackColor = System.Drawing.Color.LightGreen };
            btnAdd.Click += BtnAddMember_Click;

            Button btnEdit = new Button { Text = "Sửa", Location = new System.Drawing.Point(400, 70), Width = 80, Name = "btnEditMember", BackColor = System.Drawing.Color.Yellow };
            btnEdit.Click += BtnEditMember_Click;

            Button btnDelete = new Button { Text = "Xóa", Location = new System.Drawing.Point(400, 100), Width = 80, Name = "btnDeleteMember", BackColor = System.Drawing.Color.LightCoral };
            btnDelete.Click += BtnDeleteMember_Click;

            Button btnRefresh = new Button { Text = "Làm mới", Location = new System.Drawing.Point(500, 40), Width = 80 };
            btnRefresh.Click += (s, e) => LoadMembers();

            panel.Controls.AddRange(new Control[] { lblTitle, lblName, txtName, lblDOB, dtpDOB, lblGender, cbGender, lblPhone, txtPhone, lblType, cbType, btnAdd, btnEdit, btnDelete, btnRefresh });
            tab.Controls.Add(dgv);
            tab.Controls.Add(panel);

            mainTabControl.TabPages.Add(tab);
        }

        private void LoadMembers()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "SELECT MemberID AS [Mã], FullName AS [Tên], DOB AS [Ngày Sinh], Gender AS [Giới Tính], Phone AS [SĐT], JoinDate AS [Ngày Tham Gia], MembershipType AS [Loại] FROM Members";
                    SqlDataAdapter da = new SqlDataAdapter(query, conn);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    
                    DataGridView dgv = (DataGridView)((TabPage)mainTabControl.TabPages["Hội Viên"]).Controls["dgvMembers"];
                    dgv.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: " + ex.Message);
            }
        }

        private void DgvMembers_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                DataGridViewRow row = ((DataGridView)sender).Rows[e.RowIndex];
                
                TabPage tab = mainTabControl.TabPages["Hội Viên"];
                ((TextBox)tab.Controls["txtName"]).Text = row.Cells["Tên"].Value.ToString();
                ((DateTimePicker)tab.Controls["dtpDOB"]).Value = Convert.ToDateTime(row.Cells["Ngày Sinh"].Value);
                ((ComboBox)tab.Controls["cbGender"]).Text = row.Cells["Giới Tính"].Value.ToString();
                ((TextBox)tab.Controls["txtPhone"]).Text = row.Cells["SĐT"].Value.ToString();
                ((ComboBox)tab.Controls["cbType"]).Text = row.Cells["Loại"].Value.ToString();
            }
        }

        private void BtnAddMember_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "INSERT INTO Members (FullName, DOB, Gender, Phone, MembershipType) VALUES (@FullName, @DOB, @Gender, @Phone, @Type)";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@FullName", ((TextBox)mainTabControl.TabPages["Hội Viên"].Controls["txtName"]).Text);
                    cmd.Parameters.AddWithValue("@DOB", ((DateTimePicker)mainTabControl.TabPages["Hội Viên"].Controls["dtpDOB"]).Value);
                    cmd.Parameters.AddWithValue("@Gender", ((ComboBox)mainTabControl.TabPages["Hội Viên"].Controls["cbGender"]).Text);
                    cmd.Parameters.AddWithValue("@Phone", ((TextBox)mainTabControl.TabPages["Hội Viên"].Controls["txtPhone"]).Text);
                    cmd.Parameters.AddWithValue("@Type", ((ComboBox)mainTabControl.TabPages["Hội Viên"].Controls["cbType"]).Text);
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Thêm thành công!");
                    LoadMembers();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: " + ex.Message);
            }
        }

        private void BtnEditMember_Click(object sender, EventArgs e)
        {
            if (((DataGridView)mainTabControl.TabPages["Hội Viên"].Controls["dgvMembers"]).CurrentRow == null)
            {
                MessageBox.Show("Vui lòng chọn dòng cần sửa!");
                return;
            }

            try
            {
                int id = Convert.ToInt32(((DataGridView)mainTabControl.TabPages["Hội Viên"].Controls["dgvMembers"]).CurrentRow.Cells["Mã"].Value);
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "UPDATE Members SET FullName=@FullName, DOB=@DOB, Gender=@Gender, Phone=@Phone, MembershipType=@Type WHERE MemberID=@ID";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@FullName", ((TextBox)mainTabControl.TabPages["Hội Viên"].Controls["txtName"]).Text);
                    cmd.Parameters.AddWithValue("@DOB", ((DateTimePicker)mainTabControl.TabPages["Hội Viên"].Controls["dtpDOB"]).Value);
                    cmd.Parameters.AddWithValue("@Gender", ((ComboBox)mainTabControl.TabPages["Hội Viên"].Controls["cbGender"]).Text);
                    cmd.Parameters.AddWithValue("@Phone", ((TextBox)mainTabControl.TabPages["Hội Viên"].Controls["txtPhone"]).Text);
                    cmd.Parameters.AddWithValue("@Type", ((ComboBox)mainTabControl.TabPages["Hội Viên"].Controls["cbType"]).Text);
                    cmd.Parameters.AddWithValue("@ID", id);
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Cập nhật thành công!");
                    LoadMembers();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: " + ex.Message);
            }
        }

        private void BtnDeleteMember_Click(object sender, EventArgs e)
        {
            if (((DataGridView)mainTabControl.TabPages["Hội Viên"].Controls["dgvMembers"]).CurrentRow == null)
            {
                MessageBox.Show("Vui lòng chọn dòng cần xóa!");
                return;
            }

            if (MessageBox.Show("Bạn có chắc muốn xóa?", "Xác nhận", MessageBoxButtons.YesNo) == DialogResult.No)
                return;

            try
            {
                int id = Convert.ToInt32(((DataGridView)mainTabControl.TabPages["Hội Viên"].Controls["dgvMembers"]).CurrentRow.Cells["Mã"].Value);
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "DELETE FROM Members WHERE MemberID=@ID";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@ID", id);
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Xóa thành công!");
                    LoadMembers();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: " + ex.Message);
            }
        }
        #endregion

        #region Courts Tab
        private void CreateCourtsTab()
        {
            TabPage tab = new TabPage("Sân Đấu");
            DataGridView dgv = new DataGridView { Dock = DockStyle.Fill, Name = "dgvCourts" };
            
            Panel panel = new Panel { Dock = DockStyle.Top, Height = 120 };
            Label lblTitle = new Label { Text = "QUẢN LÝ SÂN ĐẤU", Font = new System.Drawing.Font("Arial", 14, System.Drawing.FontStyle.Bold), Location = new System.Drawing.Point(10, 10), AutoSize = true };
            
            Label lblName = new Label { Text = "Tên sân:", Location = new System.Drawing.Point(10, 40), AutoSize = true };
            TextBox txtName = new TextBox { Name = "txtCourtName", Location = new System.Drawing.Point(70, 37), Width = 150 };

            Label lblFloor = new Label { Text = "Tầng:", Location = new System.Drawing.Point(240, 40), AutoSize = true };
            NumericUpDown numFloor = new NumericUpDown { Name = "numFloor", Location = new System.Drawing.Point(280, 37), Width = 50, Minimum = 1, Maximum = 10 };

            Label lblRate = new Label { Text = "Giá/giờ:", Location = new System.Drawing.Point(10, 70), AutoSize = true };
            TextBox txtRate = new TextBox { Name = "txtRate", Location = new System.Drawing.Point(70, 67), Width = 150 };

            Label lblStatus = new Label { Text = "Trạng thái:", Location = new System.Drawing.Point(240, 70), AutoSize = true };
            ComboBox cbStatus = new ComboBox { Name = "cbCourtStatus", Location = new System.Drawing.Point(320, 67), Width = 120 };
            cbStatus.Items.AddRange(new object[] { "Available", "Maintenance", "Booked" });

            Button btnAdd = new Button { Text = "Thêm", Location = new System.Drawing.Point(500, 40), Width = 70, BackColor = System.Drawing.Color.LightGreen };
            btnAdd.Click += (s, args) => ExecuteCRUD("INSERT INTO Courts (CourtName, FloorLevel, HourlyRate, Status) VALUES (@Name, @Floor, @Rate, @Status)", 
                new object[,] { {"@Name", txtName.Text}, {"@Floor", numFloor.Value}, {"@Rate", decimal.Parse(txtRate.Text)}, {"@Status", cbStatus.Text} }, "Thêm sân thành công!", dgv, "SELECT CourtID AS [Mã], CourtName AS [Tên], FloorLevel AS [Tầng], HourlyRate AS [Giá/Giờ], Status AS [Trạng Thái] FROM Courts");

            Button btnRefresh = new Button { Text = "Làm mới", Location = new System.Drawing.Point(500, 70), Width = 70 };
            btnRefresh.Click += (s, args) => LoadDataToGrid("SELECT CourtID AS [Mã], CourtName AS [Tên], FloorLevel AS [Tầng], HourlyRate AS [Giá/Giờ], Status AS [Trạng Thái] FROM Courts", dgv);

            panel.Controls.AddRange(new Control[] { lblTitle, lblName, txtName, lblFloor, numFloor, lblRate, txtRate, lblStatus, cbStatus, btnAdd, btnRefresh });
            tab.Controls.Add(dgv);
            tab.Controls.Add(panel);
            mainTabControl.TabPages.Add(tab);
        }
        #endregion

        #region Coaches Tab
        private void CreateCoachesTab()
        {
            TabPage tab = new TabPage("Huấn Luyện Viên");
            DataGridView dgv = new DataGridView { Dock = DockStyle.Fill, Name = "dgvCoaches" };
            
            Panel panel = new Panel { Dock = DockStyle.Top, Height = 120 };
            Label lblTitle = new Label { Text = "QUẢN LÝ HLV", Font = new System.Drawing.Font("Arial", 14, System.Drawing.FontStyle.Bold), Location = new System.Drawing.Point(10, 10), AutoSize = true };
            
            Label lblName = new Label { Text = "Tên:", Location = new System.Drawing.Point(10, 40), AutoSize = true };
            TextBox txtName = new TextBox { Name = "txtCoachName", Location = new System.Drawing.Point(50, 37), Width = 150 };

            Label lblSpec = new Label { Text = "Chuyên môn:", Location = new System.Drawing.Point(220, 40), AutoSize = true };
            ComboBox cbSpec = new ComboBox { Name = "cbSpecialty", Location = new System.Drawing.Point(290, 37), Width = 120 };
            cbSpec.Items.AddRange(new object[] { "Đơn", "Đôi", "Người mới" });

            Label lblExp = new Label { Text = "Kinh nghiệm:", Location = new System.Drawing.Point(10, 70), AutoSize = true };
            NumericUpDown numExp = new NumericUpDown { Name = "numExp", Location = new System.Drawing.Point(85, 67), Width = 50, Minimum = 0, Maximum = 30 };

            Label lblSalary = new Label { Text = "Lương:", Location = new System.Drawing.Point(220, 70), AutoSize = true };
            TextBox txtSalary = new TextBox { Name = "txtSalary", Location = new System.Drawing.Point(290, 67), Width = 120 };

            Button btnAdd = new Button { Text = "Thêm", Location = new System.Drawing.Point(450, 40), Width = 70, BackColor = System.Drawing.Color.LightGreen };
            btnAdd.Click += (s, args) => ExecuteCRUD("INSERT INTO Coaches (FullName, Specialty, ExperienceYears, Salary) VALUES (@Name, @Spec, @Exp, @Salary)", 
                new object[,] { {"@Name", txtName.Text}, {"@Spec", cbSpec.Text}, {"@Exp", numExp.Value}, {"@Salary", decimal.Parse(txtSalary.Text)} }, "Thêm HLV thành công!", dgv, "SELECT CoachID AS [Mã], FullName AS [Tên], Specialty AS [Chuyên Môn], ExperienceYears AS [Kinh Nghiệm], Salary AS [Lương] FROM Coaches");

            Button btnRefresh = new Button { Text = "Làm mới", Location = new System.Drawing.Point(450, 70), Width = 70 };
            btnRefresh.Click += (s, args) => LoadDataToGrid("SELECT CoachID AS [Mã], FullName AS [Tên], Specialty AS [Chuyên Môn], ExperienceYears AS [Kinh Nghiệm], Salary AS [Lương] FROM Coaches", dgv);

            panel.Controls.AddRange(new Control[] { lblTitle, lblName, txtName, lblSpec, cbSpec, lblExp, numExp, lblSalary, txtSalary, btnAdd, btnRefresh });
            tab.Controls.Add(dgv);
            tab.Controls.Add(panel);
            mainTabControl.TabPages.Add(tab);
        }
        #endregion

        #region Bookings Tab
        private void CreateBookingsTab()
        {
            TabPage tab = new TabPage("Đặt Sân");
            DataGridView dgv = new DataGridView { Dock = DockStyle.Fill, Name = "dgvBookings" };
            
            Panel panel = new Panel { Dock = DockStyle.Top, Height = 150 };
            Label lblTitle = new Label { Text = "ĐẶT SÂN", Font = new System.Drawing.Font("Arial", 14, System.Drawing.FontStyle.Bold), Location = new System.Drawing.Point(10, 10), AutoSize = true };
            
            Label lblMember = new Label { Text = "Mã HV:", Location = new System.Drawing.Point(10, 40), AutoSize = true };
            TextBox txtMemberID = new TextBox { Name = "txtMemberID", Location = new System.Drawing.Point(60, 37), Width = 80 };

            Label lblCourt = new Label { Text = "Mã sân:", Location = new System.Drawing.Point(160, 40), AutoSize = true };
            TextBox txtCourtID = new TextBox { Name = "txtCourtID", Location = new System.Drawing.Point(210, 37), Width = 80 };

            Label lblDate = new Label { Text = "Ngày:", Location = new System.Drawing.Point(10, 70), AutoSize = true };
            DateTimePicker dtpDate = new DateTimePicker { Name = "dtpBookingDate", Location = new System.Drawing.Point(60, 67), Width = 150 };

            Label lblStart = new Label { Text = "Giờ bắt đầu:", Location = new System.Drawing.Point(230, 70), AutoSize = true };
            MaskedTextBox txtStart = new MaskedTextBox { Name = "txtStartTime", Mask = "00:00", Location = new System.Drawing.Point(310, 67), Width = 80 };

            Label lblEnd = new Label { Text = "Giờ kết thúc:", Location = new System.Drawing.Point(10, 100), AutoSize = true };
            MaskedTextBox txtEnd = new MaskedTextBox { Name = "txtEndTime", Mask = "00:00", Location = new System.Drawing.Point(90, 97), Width = 80 };

            Label lblStatus = new Label { Text = "Trạng thái:", Location = new System.Drawing.Point(190, 100), AutoSize = true };
            ComboBox cbStatus = new ComboBox { Name = "cbBookingStatus", Location = new System.Drawing.Point(260, 97), Width = 120 };
            cbStatus.Items.AddRange(new object[] { "Pending", "Confirmed", "Cancelled", "Completed" });

            Button btnAdd = new Button { Text = "Đặt sân", Location = new System.Drawing.Point(450, 40), Width = 100, BackColor = System.Drawing.Color.LightGreen };
            btnAdd.Click += (s, args) =>
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        string query = "EXEC USP_MakeBooking @MemberID, @CourtID, @Date, @Start, @End";
                        SqlCommand cmd = new SqlCommand(query, conn);
                        cmd.Parameters.AddWithValue("@MemberID", int.Parse(txtMemberID.Text));
                        cmd.Parameters.AddWithValue("@CourtID", int.Parse(txtCourtID.Text));
                        cmd.Parameters.AddWithValue("@Date", dtpDate.Value.Date);
                        cmd.Parameters.AddWithValue("@Start", TimeSpan.Parse(txtStart.Text));
                        cmd.Parameters.AddWithValue("@End", TimeSpan.Parse(txtEnd.Text));
                        cmd.ExecuteNonQuery();
                        MessageBox.Show("Đặt sân thành công!");
                        LoadDataToGrid("SELECT BookingID AS [Mã], MemberID AS [Mã HV], CourtID AS [Mã Sân], BookingDate AS [Ngày], StartTime AS [Giờ BĐ], EndTime AS [Giờ KT], TotalAmount AS [Tổng Tiền], Status AS [Trạng Thái] FROM Bookings", dgv);
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Lỗi: " + ex.Message);
                }
            };

            Button btnRefresh = new Button { Text = "Làm mới", Location = new System.Drawing.Point(450, 70), Width = 100 };
            btnRefresh.Click += (s, args) => LoadDataToGrid("SELECT BookingID AS [Mã], MemberID AS [Mã HV], CourtID AS [Mã Sân], BookingDate AS [Ngày], StartTime AS [Giờ BĐ], EndTime AS [Giờ KT], TotalAmount AS [Tổng Tiền], Status AS [Trạng Thái] FROM Bookings", dgv);

            panel.Controls.AddRange(new Control[] { lblTitle, lblMember, txtMemberID, lblCourt, txtCourtID, lblDate, dtpDate, lblStart, txtStart, lblEnd, txtEnd, lblStatus, cbStatus, btnAdd, btnRefresh });
            tab.Controls.Add(dgv);
            tab.Controls.Add(panel);
            mainTabControl.TabPages.Add(tab);
        }
        #endregion

        #region Payments Tab
        private void CreatePaymentsTab()
        {
            TabPage tab = new TabPage("Thanh Toán");
            DataGridView dgv = new DataGridView { Dock = DockStyle.Fill, Name = "dgvPayments" };
            
            Panel panel = new Panel { Dock = DockStyle.Top, Height = 120 };
            Label lblTitle = new Label { Text = "THANH TOÁN", Font = new System.Drawing.Font("Arial", 14, System.Drawing.FontStyle.Bold), Location = new System.Drawing.Point(10, 10), AutoSize = true };
            
            Label lblBooking = new Label { Text = "Mã đặt:", Location = new System.Drawing.Point(10, 40), AutoSize = true };
            TextBox txtBookingID = new TextBox { Name = "txtBookingID", Location = new System.Drawing.Point(60, 37), Width = 80 };

            Label lblMember = new Label { Text = "Mã HV:", Location = new System.Drawing.Point(160, 40), AutoSize = true };
            TextBox txtMemberID = new TextBox { Name = "txtPayMemberID", Location = new System.Drawing.Point(210, 37), Width = 80 };

            Label lblAmount = new Label { Text = "Số tiền:", Location = new System.Drawing.Point(10, 70), AutoSize = true };
            TextBox txtAmount = new TextBox { Name = "txtAmount", Location = new System.Drawing.Point(60, 67), Width = 150 };

            Label lblMethod = new Label { Text = "Phương thức:", Location = new System.Drawing.Point(230, 70), AutoSize = true };
            ComboBox cbMethod = new ComboBox { Name = "cbPaymentMethod", Location = new System.Drawing.Point(310, 67), Width = 120 };
            cbMethod.Items.AddRange(new object[] { "Tiền mặt", "Chuyển khoản", "Thẻ" });

            Button btnAdd = new Button { Text = "Thanh toán", Location = new System.Drawing.Point(480, 40), Width = 100, BackColor = System.Drawing.Color.LightGreen };
            btnAdd.Click += (s, args) => ExecuteCRUD("INSERT INTO Payments (BookingID, MemberID, Amount, PaymentMethod) VALUES (@BookingID, @MemberID, @Amount, @Method)", 
                new object[,] { {"@BookingID", int.Parse(txtBookingID.Text)}, {"@MemberID", int.Parse(txtPayMemberID.Text)}, {"@Amount", decimal.Parse(txtAmount.Text)}, {"@Method", cbMethod.Text} }, "Thanh toán thành công!", dgv, "SELECT PaymentID AS [Mã], BookingID AS [Mã Đặt], MemberID AS [Mã HV], Amount AS [Số Tiền], PaymentDate AS [Ngày Thanh Toán], PaymentMethod AS [Phương Thức] FROM Payments");

            Button btnRefresh = new Button { Text = "Làm mới", Location = new System.Drawing.Point(480, 70), Width = 100 };
            btnRefresh.Click += (s, args) => LoadDataToGrid("SELECT PaymentID AS [Mã], BookingID AS [Mã Đặt], MemberID AS [Mã HV], Amount AS [Số Tiền], PaymentDate AS [Ngày Thanh Toán], PaymentMethod AS [Phương Thức] FROM Payments", dgv);

            panel.Controls.AddRange(new Control[] { lblTitle, lblBooking, txtBookingID, lblMember, txtMemberID, lblAmount, txtAmount, lblMethod, cbMethod, btnAdd, btnRefresh });
            tab.Controls.Add(dgv);
            tab.Controls.Add(panel);
            mainTabControl.TabPages.Add(tab);
        }
        #endregion

        #region Reports Tab
        private void CreateReportsTab()
        {
            TabPage tab = new TabPage("Báo Cáo & Thống Kê");
            
            FlowLayoutPanel flowPanel = new FlowLayoutPanel { Dock = DockStyle.Top, Height = 200, WrapContents = true };
            
            Button btnRevenue = new Button { Text = "Doanh thu theo tháng", Width = 150, Height = 50, Margin = new Padding(10) };
            btnRevenue.Click += (s, e) => ShowReport("SELECT MONTH(PaymentDate) AS [Tháng], SUM(Amount) AS [Doanh Thu] FROM Payments GROUP BY MONTH(PaymentDate) ORDER BY [Tháng]");
            
            Button btnMemberByType = new Button { Text = "Thành viên theo loại", Width = 150, Height = 50, Margin = new Padding(10) };
            btnMemberByType.Click += (s, e) => ShowReport("EXEC USP_CountMembersByType");
            
            Button btnCourtUsage = new Button { Text = "Sử dụng sân theo tầng", Width = 150, Height = 50, Margin = new Padding(10) };
            btnCourtUsage.Click += (s, e) => ShowReport("SELECT FloorLevel AS [Tầng], COUNT(*) AS [Số Lượng] FROM Courts GROUP BY FloorLevel");
            
            Button btnTopMembers = new Button { Text = "Top 5 thành viên chi tiêu", Width = 150, Height = 50, Margin = new Padding(10) };
            btnTopMembers.Click += (s, e) => ShowReport("SELECT TOP 5 M.FullName AS [Tên], SUM(P.Amount) AS [Tổng Chi Tiêu] FROM Members M JOIN Payments P ON M.MemberID = P.MemberID GROUP BY M.FullName ORDER BY [Tổng Chi Tiêu] DESC");
            
            Button btnBookingStatus = new Button { Text = "Trạng thái đặt sân", Width = 150, Height = 50, Margin = new Padding(10) };
            btnBookingStatus.Click += (s, e) => ShowReport("SELECT Status AS [Trạng Thái], COUNT(*) AS [Số Lượng] FROM Bookings GROUP BY Status");

            Button btnCoachSessions = new Button { Text = "Số buổi tập theo HLV", Width = 150, Height = 50, Margin = new Padding(10) };
            btnCoachSessions.Click += (s, e) => ShowReport("SELECT C.FullName AS [HLV], COUNT(CS.SessionID) AS [Số Buổi] FROM Coaches C LEFT JOIN CoachingSessions CS ON C.CoachID = CS.CoachID GROUP BY C.FullName");

            Button btnEquipmentByCategory = new Button { Text = "Thiết bị theo danh mục", Width = 150, Height = 50, Margin = new Padding(10) };
            btnEquipmentByCategory.Click += (s, e) => ShowReport("SELECT Category AS [Danh Mục], SUM(Quantity) AS [Tổng SL] FROM Equipment GROUP BY Category");

            flowPanel.Controls.AddRange(new Control[] { btnRevenue, btnMemberByType, btnCourtUsage, btnTopMembers, btnBookingStatus, btnCoachSessions, btnEquipmentByCategory });

            DataGridView dgvReport = new DataGridView { Dock = DockStyle.Fill, Name = "dgvReport" };
            
            tab.Controls.Add(dgvReport);
            tab.Controls.Add(flowPanel);
            mainTabControl.TabPages.Add(tab);
        }

        private void ShowReport(string query)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    SqlDataAdapter da = new SqlDataAdapter(query, conn);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    DataGridView dgv = (DataGridView)((TabPage)mainTabControl.TabPages["Báo Cáo & Thống Kê"]).Controls["dgvReport"];
                    dgv.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: " + ex.Message);
            }
        }
        #endregion

        #region Helper Methods
        private void LoadDataToGrid(string query, DataGridView dgv)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    SqlDataAdapter da = new SqlDataAdapter(query, conn);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    dgv.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: " + ex.Message);
            }
        }

        private void ExecuteCRUD(string query, object[,] parameters, string successMsg, DataGridView dgv, string selectQuery)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(query, conn);
                    for (int i = 0; i < parameters.GetLength(0); i++)
                    {
                        cmd.Parameters.AddWithValue(parameters[i, 0].ToString(), parameters[i, 1]);
                    }
                    cmd.ExecuteNonQuery();
                    MessageBox.Show(successMsg);
                    LoadDataToGrid(selectQuery, dgv);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: " + ex.Message);
            }
        }
        #endregion
    }
}
