import UIKit
import SnapKit

final class TestCell: UICollectionViewCell, ReuseIdentifierable {

  // MARK: - UI Properties

  private lazy var containerView = buildContainerView()
  private lazy var titleLabel1 = buildTitleLabel1()
  private lazy var titleLabel2 = buildTitleLabel2()

  // MARK: - Instance Properties

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupLayout()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Life-Cycle Methods

  override func prepareForReuse() {
    super.prepareForReuse()
    
    titleLabel1.text = nil
    titleLabel2.text = nil
  }
}

// MARK: - Setup Layout

private extension TestCell {
  func setupLayout() {
    contentView.addSubview(containerView)
    containerView.addSubview(titleLabel1)
    containerView.addSubview(titleLabel2)
    
    containerView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
    }
    titleLabel1.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
    }
    titleLabel2.snp.makeConstraints { make in
      make.top.equalTo(titleLabel1.snp.bottom)
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
}

// MARK: - Public Methods

extension TestCell {
  func configure(testData: TestModel) {
    Logg.d("id: \(testData.id) / title: \(testData.title)")
    titleLabel1.text = testData.id
    titleLabel2.text = testData.title
  }
}

// MARK: - Build UI Property

private extension TestCell {
  func buildContainerView() -> UIView {
    UIView()
  }
  
  func buildTitleLabel1() -> UILabel {
    let result = UILabel()
    result.textColor = .white
    result.font = .systemFont(ofSize: 13, weight: .regular)
    result.textAlignment = .center
    result.numberOfLines = 1
    result.adjustsFontSizeToFitWidth = true
    result.minimumScaleFactor = 0.1
    return result
  }
  
  func buildTitleLabel2() -> UILabel {
    let result = UILabel()
    result.textColor = .white
    result.font = .systemFont(ofSize: 13, weight: .regular)
    result.textAlignment = .center
    result.numberOfLines = 1
    result.adjustsFontSizeToFitWidth = true
    result.minimumScaleFactor = 0.1
    return result
  }
}
