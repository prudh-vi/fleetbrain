import SwiftUI

struct ContentView: View {
    @StateObject var vm = FleetViewModel()

    var body: some View {
        TabView {
            // Dashboard Tab
            ZStack {
                Color.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Header matching mock
                        HStack(spacing: 12) {
                            // Purple squircle logo
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "#6B72ED"))
                                    .frame(width: 38, height: 38)
                                Image(systemName: "bolt")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text("FleetBrain")
                                .font(.system(size: 24, weight: .heavy))
                                .foregroundColor(.textPrimary)

                            Spacer()

                            HStack(spacing: 4) {
                                Text("\(vm.anomalies.count) LIVE")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.cardBorder)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 2)

                            HStack(spacing: 16) {
                                Image(systemName: "gearshape")
                                    .foregroundColor(.textPrimary)
                                    .font(.system(size: 18))
                                Image(systemName: "person.crop.circle")
                                    .foregroundColor(.textPrimary)
                                    .font(.system(size: 18))
                            }
                            .padding(.leading, 4)
                        }
                        .padding(.top, 8)

                        // Tab Pill Selector Mock
                        HStack(spacing: 0) {
                            Text("Realtime")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.primary)
                                .cornerRadius(24)

                            Text("Daily")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.textSecondary)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)

                            Text("Weekly")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.textSecondary)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(4)
                        .background(Color.card)
                        .cornerRadius(28)
                        .shadow(color: Color.black.opacity(0.03), radius: 4)
                        .padding(.bottom, 4)

                        // Stats
                        HStack(spacing: 16) {
                            StatCard(title: "Alerts", value: "\(vm.anomalies.count)", color: .accent, icon: "car.side.fill")
                            StatCard(title: "Critical", value: "\(vm.criticalCount)", color: .primary, icon: "exclamationmark.triangle.fill")
                        }

                        // Map
                        MapView(anomalies: vm.anomalies)

                        // Chart
                        AnomalyChart(anomalies: vm.anomalies)

                        // Feed Header
                        HStack {
                            Text("Recent Incidents")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)

                            Spacer()

                            Text("View All")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top, 12)

                        // Alerts
                        VStack(spacing: 14) {
                            ForEach(vm.anomalies, id: \.uuid) { anomaly in
                                AlertCard(anomaly: anomaly)
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .tabItem {
                Label("Dashboard", systemImage: "square.grid.2x2.fill")
            }

            Text("Orders View")
                .tabItem {
                    Label("Orders", systemImage: "tray.full.fill")
                }

            Text("Customers View")
                .tabItem {
                    Label("Customers", systemImage: "person.2.fill")
                }

            Text("Settings View")
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(Color.accent)
        .onAppear {
            vm.loadInitial()
            vm.startLiveUpdates()
        }
    }
}
